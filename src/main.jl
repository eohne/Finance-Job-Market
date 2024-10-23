include("install_dep.jl")

# Import necessary packages
install_dep("HTTP", "Gumbo", "DataFrames","ProgressMeter","CSV","Dates","JSON3");


# Function to get user input with validation
function get_user_input(prompt::String, valid_options::Vector{String})
    while true
        print(prompt)
        response = lowercase(strip(readline()))
        if response in valid_options
            return response == "y" || response == "yes"
        end
        println("Please enter one of: ", join(valid_options, ", "))
    end
end

# Get user preferences for AI usage
println("Job Posting Scraper Configuration")
println("=================================")
use_ai = get_user_input("Do you want to use AI for information extraction? (y/n): ", ["y", "yes", "n", "no"])

# Only ask about Ollama if AI is requested
ollama = false
mistral_api_key = "api_key"
if use_ai
    println("Checking if AI packages are installed...")
    install_dep("Suppressor")
    @suppress_out begin  # Suppresses stdout
        install_dep("PromptingTools");
    end
    include("ai_summary.jl");
    ollama = get_user_input("Do you want to use Ollama (local) instead of Mistral API? (y/n): ", ["y", "yes", "n", "no"])

    if !ollama
        print("Please enter your Mistral API key (press Enter to skip): ")
        input_key = readline()
        if !isempty(input_key)
            mistral_api_key = input_key
        end
    end
end

# Set paths for data files
const output_path = "Output/Jobs.csv"
const ssrn_path = "Data/ssrn.csv"
const afa_path = "Data/afa.csv"
const ssrn_ai_path = "Data/ssrn_ai.csv"
const afa_ai_path = "Data/afa_ai.csv"

# Include scrapers
include("ssrn_scraper.jl")
include("afa_scraper.jl")

# Modified append_to_csv to include timestamp
function append_to_csv(new_data::DataFrame, filepath::String)
    if isempty(new_data)
        return new_data
    end
    
    # Add timestamp and initialize flags
    new_data[!, :timestamp] .= Dates.now()
    new_data[!, :old] .= 0
    new_data[!, :used_ai] .= 0
    
    if isfile(filepath)
        existing_data = CSV.read(filepath, DataFrame)
        existing_data[!, :old] .= 1
        
        # Ensure used_ai column exists
        if !hasproperty(existing_data, :used_ai)
            existing_data[!, :used_ai] .= 0
        end
        
        # Ensure timestamp column exists
        if !hasproperty(existing_data, :timestamp)
            existing_data[!, :timestamp] .= missing
        end
        
        append!(new_data, existing_data)
        CSV.write(filepath, new_data)
    else
        CSV.write(filepath, new_data)
    end
    
    return new_data
end

# Retrieve and process SSRN jobs
println("\nRetrieving SSRN job postings...")
ssrn_table = ssrn_jobs()
ssrn_table = append_to_csv(ssrn_table, ssrn_path)

# Retrieve and process AFA jobs
println("\nRetrieving AFA job postings...")
afa_table = afa_jobs()
afa_table = append_to_csv(afa_table, afa_path)


# Function to append AI results to storage
function append_ai_results(new_ai_data::DataFrame, filepath::String)
    if isempty(new_ai_data)
        return new_ai_data
    end
    
    if isfile(filepath)
        existing_ai = CSV.read(filepath, DataFrame)
        append!(new_ai_data, existing_ai)  # combine with existing AI results
        CSV.write(filepath, new_ai_data)
    else
        CSV.write(filepath, new_ai_data)
    end
    
    return new_ai_data
end


# Process with AI if requested and possible
if use_ai
    if ollama
        println("\nUsing Ollama for AI processing...")
    elseif isequal(mistral_api_key, "api_key")
        @warn "Ollama set to false and mistral_api_key not set! Will skip AI extraction."
        use_ai = false
    else
        println("\nUsing Mistral API for AI processing...")
    end
end


# Initialize variables for AI results
# Initialize variables for AI results
ssrn_ai_results = DataFrame()
afa_ai_results = DataFrame()

# Process new entries with AI and load existing AI results
if use_ai
    # Filter for new entries only
    new_ssrn = filter(row -> row.old == 0, ssrn_table)
    new_afa = filter(row -> row.old == 0, afa_table)
    
    # Process new entries
    if !isempty(new_ssrn)
        println("Processing new SSRN entries with AI...")
        ssrn_ai_new = process_html_batch(new_ssrn.Html; ollama=ollama)
        # Add Html column for joining
        ssrn_ai_new[!, :Html] = new_ssrn.Html
        # Update AI flag for processed entries
        ssrn_table[ssrn_table.old .== 0, :used_ai] .= 1
        # Store new AI results
        ssrn_ai_results = append_ai_results(ssrn_ai_new, ssrn_ai_path)
    else
        # If no new entries, just load existing AI results if available
        if isfile(ssrn_ai_path)
            ssrn_ai_results = CSV.read(ssrn_ai_path, DataFrame)
        end
    end
    
    if !isempty(new_afa)
        println("Processing new AFA entries with AI...")
        afa_ai_new = process_html_batch(new_afa.Description; ollama=ollama)
        # Add Description column for joining
        afa_ai_new[!, :Description] = new_afa.Description
        # Update AI flag for processed entries
        afa_table[afa_table.old .== 0, :used_ai] .= 1
        # Store new AI results
        afa_ai_results = append_ai_results(afa_ai_new, afa_ai_path)
    else
        # If no new entries, just load existing AI results if available
        if isfile(afa_ai_path)
            afa_ai_results = CSV.read(afa_ai_path, DataFrame)
        end
    end
end

# Modified append_ai_results to ensure HTML/Description columns are always present
function append_ai_results(new_ai_data::DataFrame, filepath::String)
    if isempty(new_ai_data)
        return new_ai_data
    end
    
    if isfile(filepath)
        existing_ai = CSV.read(filepath, DataFrame)
        
        # Ensure joining columns are present in both DataFrames
        if occursin("ssrn", lowercase(filepath)) && !hasproperty(existing_ai, :Html)
            @warn "Adding missing Html column to existing AI results"
            existing_ai[!, :Html] = missing
        end
        if occursin("afa", lowercase(filepath)) && !hasproperty(existing_ai, :Description)
            @warn "Adding missing Description column to existing AI results"
            existing_ai[!, :Description] = missing
        end
        
        append!(new_ai_data, existing_ai)  # combine with existing AI results
        CSV.write(filepath, new_ai_data)
    else
        CSV.write(filepath, new_ai_data)
    end
    
    return new_ai_data
end

# Modified prepare_final_output to ensure proper joining
function prepare_final_output(ssrn_df, afa_df, use_ai::Bool, ssrn_ai=nothing, afa_ai=nothing)
    # Create copies to avoid modifying original data
    ssrn_output = copy(ssrn_df)
    afa_output = copy(afa_df)
    
    # Add source column
    ssrn_output[!, :source] .= "SSRN"
    afa_output[!, :source] .= "AFA"
    
    if use_ai
        # Handle SSRN data
        if !isnothing(ssrn_ai) && !isempty(ssrn_ai)
            if !hasproperty(ssrn_ai, :Html)
                @error "SSRN AI results missing Html column required for joining"
                return vcat(ssrn_output, afa_output, cols=:union)
            end
            # Store AI deadline separately and remove from ssrn_ai
            ai_deadline = ssrn_ai[!, :Deadline]
            select!(ssrn_ai, Not(:Deadline))
            # Join AI results
            ssrn_output = leftjoin(ssrn_output, ssrn_ai, on=:Html)
            # Only replace Deadline with AI version if AI version exists
            for (i, deadline) in enumerate(ai_deadline)
                if !ismissing(deadline) && !isnothing(deadline) && !isempty(deadline)
                    ssrn_output[i, :Deadline] = deadline
                end
            end
        end
        
        # Handle AFA data
        if !isnothing(afa_ai) && !isempty(afa_ai)
            if !hasproperty(afa_ai, :Description)
                @error "AFA AI results missing Description column required for joining"
                return vcat(ssrn_output, afa_output, cols=:union)
            end
            # First rename original Deadline to AFADeadline
            rename!(afa_output, :Deadline => :AFADeadline)
            # Add new Deadline column initialized with AFADeadline values
            afa_output[!, :Deadline] = afa_output[!, :AFADeadline]
            # Join AI results
            afa_output = leftjoin(afa_output, afa_ai, on=:Description)
            # Replace Deadline with AI version only where AI version exists
            for i in 1:nrow(afa_output)
                if !ismissing(afa_ai_deadline) && !isnothing(afa_ai_deadline) && !isempty(afa_ai_deadline)
                    afa_output[i, :Deadline] = afa_ai_deadline
                end
                # If AI deadline is missing/empty, we already have the AFA deadline as fallback
            end
        end
    end
    
    # Combine both sources
    combined = vcat(ssrn_output, afa_output, cols=:union)
    
    # Sort by timestamp (newest first)
    sort!(combined, :timestamp, rev=true)
    
    return combined
end

# Prepare and save final output using all AI results
println("\nPreparing final output...")
final_output = prepare_final_output(
    ssrn_table, 
    afa_table,
    use_ai,
    use_ai ? ssrn_ai_results : nothing, 
    use_ai ? afa_ai_results : nothing
)
# Save final output
CSV.write(output_path, final_output)
println("Done! Output saved to: ", output_path)