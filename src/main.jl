loc = @__DIR__
if isnothing(loc)
    global loc = @__FILE__
end 
cd(loc)
function print_banner()
    println("\n")
    println("\033[1;36m  ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗         ███╗ ██████╗ ██████╗")
    println("  ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝          ██║██╔═══██╗██╔══██╗")
    println("  █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗            ██║██║   ██║██████╔╝")
    println("  ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝      ██    ██║██║   ██║██╔══██╗")
    println("  ██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗    ████████║╚██████╔╝██████╔╝")
    println("  ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝    ╚═══════╝ ╚═════╝ ╚═════╝\033[0m")
    println("\033[1;36m  ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗       ███████╗ ██████╗██████╗  █████╗ ██████╗ ███████╗██████╗")
    println("  ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝       ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗")
    println("  ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║          ███████╗██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝")
    println("  ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║          ╚════██║██║     ██╔══██╗██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗")
    println("  ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║          ███████║╚██████╗██║  ██║██║  ██║██║     ███████╗██║  ██║")
    println("  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝\033[0m")
    println("\033[1;36m  ════════════════════════════════════════════════ 🎓 Version 1.0 ════════════════════════════════════════════════\033[0m")
    println("\033[1;36m                                                                                                 by Elias Ohneberg\033[0m")
    println()
end
print_banner()

function install_dep(x::String...)
    println("\n\033[1;36m📦 Checking Package Dependencies\033[0m")
    println("═══════════════════════════")
    for pkg in x
        if !isnothing(Base.find_package(pkg))
            println("\033[1;32m✓\033[0m $pkg")
            nothing
        else
            println("\033[1;33m⟳\033[0m Installing: $pkg")
            Pkg.add(pkg)
            println("\033[1;32m✓\033[0m $pkg installed")
        end
    end
    println("\033[1;32m✨ All packages ready!\033[0m")
    println()
    return nothing
end;
function print_warning(msg::String)
    println("\033[1;33m⚠️  Warning: $msg\033[0m")
end

using Pkg
install_dep("HTTP", "Gumbo", "DataFrames","ProgressMeter","CSV","Dates","JSON3","Suppressor","PromptingTools");


module FinJobScraper

using HTTP, Gumbo, DataFrames,ProgressMeter, CSV, Dates , JSON3 , Suppressor
@suppress begin
    using PromptingTools
end
export main, clear_keep_banner


function clear_keep_banner()
    # Clear screen
    if Sys.iswindows()
        run(`cmd /c cls`)
    else
        run(`clear`)
    end
    println("\n")
    println("\033[1;36m  ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗         ███╗ ██████╗ ██████╗")
    println("  ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝          ██║██╔═══██╗██╔══██╗")
    println("  █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗            ██║██║   ██║██████╔╝")
    println("  ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝      ██    ██║██║   ██║██╔══██╗")
    println("  ██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗    ████████║╚██████╔╝██████╔╝")
    println("  ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝    ╚═══════╝ ╚═════╝ ╚═════╝\033[0m")
    println("\033[1;36m  ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗       ███████╗ ██████╗██████╗  █████╗ ██████╗ ███████╗██████╗")
    println("  ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝       ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗")
    println("  ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║          ███████╗██║     ██████╔╝███████║██████╔╝█████╗  ██████╔╝")
    println("  ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║          ╚════██║██║     ██╔══██╗██╔══██║██╔═══╝ ██╔══╝  ██╔══██╗")
    println("  ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║          ███████║╚██████╗██║  ██║██║  ██║██║     ███████╗██║  ██║")
    println("  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝\033[0m")
    println()
end
include("ssrn_scraper.jl")
include("afa_scraper.jl")
include("ai_summary.jl");

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


function append_to_csv(new_data::DataFrame, filepath::String)
    if isempty(new_data)
        # If no new data, load and return existing data
        if isfile(filepath)
            return CSV.read(filepath, DataFrame)
        end
        return new_data
    end

    # Add timestamp and initialize flags
    if !hasproperty(new_data, :timestamp)
        new_data[!, :timestamp] .= Dates.now()
    end
    if !hasproperty(new_data, :old)
        new_data[!, :old] .= 0
    end
    if !hasproperty(new_data, :used_ai)
        new_data[!, :used_ai] .= 0
    end
    
    if isfile(filepath)
        existing_data = CSV.read(filepath, DataFrame)
        
        # Ensure all required columns exist in existing data
        if !hasproperty(existing_data, :old)
            existing_data[!, :old] .= 1
        end
        if !hasproperty(existing_data, :used_ai)
            existing_data[!, :used_ai] .= 0
        end
        if !hasproperty(existing_data, :timestamp)
            existing_data[!, :timestamp] .= missing
        end
        
        # Combine existing and new data
        combined = vcat(existing_data, new_data, cols=:union)
        CSV.write(filepath, combined)
        return combined
    else
        CSV.write(filepath, new_data)
        return new_data
    end
end

function get_text_only(str::String)
    res = parsehtml(str)
    res = text(res.root)
    return res
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
            print_warning("Missing Html column in SSRN AI results")
            existing_ai[!, :Html] = missing
        end
        if occursin("afa", lowercase(filepath)) && !hasproperty(existing_ai, :Description)
            print_warning("Missing Description column in AFA AI results")
            existing_ai[!, :Description] = missing
        end
        
        append!(new_ai_data, existing_ai,promote=true)  # combine with existing AI results
        CSV.write(filepath, new_ai_data)
    else
        CSV.write(filepath, new_ai_data)
    end
    
    return new_ai_data
end


function prepare_final_output(ssrn_df, afa_df, use_ai::Bool, ssrn_ai=nothing, afa_ai=nothing)
    # Count new entries (where old == 0)
    new_ssrn_count = nrow(filter(row -> row.old == 0, ssrn_df))
    new_afa_count = nrow(filter(row -> row.old == 0, afa_df))
    
    # Create copies to avoid modifying original data
    ssrn_output = copy(ssrn_df)  # Remove isempty check to keep existing data
    afa_output = copy(afa_df)    # Remove isempty check to keep existing data
    
    # Add source columns
    if !isempty(ssrn_output)
        ssrn_output[!, :source] .= "SSRN"
    end
    
    if !isempty(afa_output)
        afa_output[!, :source] .= "AFA"
    end
    
    if use_ai
        # Load existing AI results first
        existing_ssrn_ai = isfile(ssrn_ai_path) ? CSV.read(ssrn_ai_path, DataFrame) : DataFrame()
        existing_afa_ai = isfile(afa_ai_path) ? CSV.read(afa_ai_path, DataFrame) : DataFrame()
        
        # Handle SSRN data - both new and old
        if !isempty(ssrn_output)
            if !isempty(existing_ssrn_ai)
                if !hasproperty(existing_ssrn_ai, :Html)
                    print_warning("Missing HTML column in SSRN AI data - join operation may fail")
                else
                    # Store AI deadline separately and remove from ssrn_ai
                    ai_deadline = existing_ssrn_ai[!, :Deadline]
                    select!(existing_ssrn_ai, Not(:Deadline))
                    
                    # Join AI results with all SSRN data (both new and old)
                    ssrn_output = leftjoin(ssrn_output, existing_ssrn_ai, on=:Html)
                    
                    # Update deadlines where we have AI results
                    for (i, row) in enumerate(eachrow(ssrn_output))
                        matched_ai_row = findfirst(==(row.Html), existing_ssrn_ai.Html)
                        if !isnothing(matched_ai_row) && matched_ai_row <= length(ai_deadline)
                            deadline = ai_deadline[matched_ai_row]
                            if !ismissing(deadline) && !isnothing(deadline) && 
                               !isempty(deadline) && !isequal(deadline, " ")
                                ssrn_output[i, :Deadline] = deadline
                            end
                        end
                    end
                end
            end
        end
        
        # Handle AFA data - both new and old
        if !isempty(afa_output)
            if !isempty(existing_afa_ai)
                if !hasproperty(existing_afa_ai, :Description)
                    print_warning("Missing Description column in AFA AI data - join operation may fail")
                else
                    # First rename original Deadline to AFADeadline if it exists
                    if hasproperty(afa_output, :Deadline)
                        rename!(afa_output, :Deadline => :AFADeadline)
                    else
                        afa_output[!, :AFADeadline] = missing
                    end
                    
                    # Join AI results with all AFA data (both new and old)
                    afa_output = leftjoin(afa_output, existing_afa_ai, on=:Description)
                    
                    # Ensure Deadline column exists
                    if !hasproperty(afa_output, :Deadline)
                        afa_output[!, :Deadline] = copy(afa_output[!, :AFADeadline])
                    end
                    
                    # Replace Deadline with AI version only where AI version exists
                    transform!(afa_output, 
                        [:Deadline, :AFADeadline] => 
                        ByRow((d,ad) -> ismissing(d) || isnothing(d) || isequal(d," ") ? ad : d) => 
                        :Deadline
                    )
                end
            end
        end
    end
    
    # Print AI processing status if AI was used
    if use_ai
        println("\n\033[1;36m🤖 AI Processing Status\033[0m")
        println("═══════════════════════")
        if new_ssrn_count > 0
            println("\033[1;32m✓\033[0m Processed $(new_ssrn_count) SSRN job$(new_ssrn_count == 1 ? "" : "s")")
        end
        if new_afa_count > 0
            println("\033[1;32m✓\033[0m Processed $(new_afa_count) AFA job$(new_afa_count == 1 ? "" : "s")")
        end
        if new_ssrn_count == 0 && new_afa_count == 0
            println("ℹ️  No new jobs to process")
        end
        println("═══════════════════════")
    end
    
    # Combine both sources, handling empty DataFrames
    if isempty(ssrn_output) && isempty(afa_output)
        return DataFrame()
    elseif isempty(ssrn_output)
        combined = afa_output
    elseif isempty(afa_output)
        combined = ssrn_output
    else
        combined = vcat(ssrn_output, afa_output, cols=:union)
    end
    
    # Sort by timestamp (newest first) if the column exists
    if hasproperty(combined, :timestamp)
        sort!(combined, :timestamp, rev=true)
    end
    
    # Print final status (using correct DataFrame counting methods)
    total_jobs = nrow(combined)
    ssrn_jobs = nrow(filter(row -> row.source == "SSRN", combined))
    afa_jobs = nrow(filter(row -> row.source == "AFA", combined))
    
    println("\n\033[1;36m📈 Database Summary\033[0m")
    println("═══════════════")
    println("📊 Total entries: \033[1m$total_jobs\033[0m")
    println("   ├─ SSRN: \033[1m$ssrn_jobs\033[0m")
    println("   └─ AFA:  \033[1m$afa_jobs\033[0m")
    
    return combined
end

const output_path = "../Output/Jobs.csv"
const ssrn_path = "../Data/ssrn.csv"
const afa_path = "../Data/afa.csv"
const ssrn_ai_path = "../Data/ssrn_ai.csv"
const afa_ai_path = "../Data/afa_ai.csv"


use_ai = true; ollama = false; 
function main()

    clear_keep_banner()
    # Configuration section
    println("\033[1;36m📋 Configuration\033[0m")
    println("══════════════")
    use_ai = get_user_input("\033[1m🤖 Use AI for information extraction?\033[0m (y/n): ", ["y", "yes", "n", "no"])

    # Only ask about Ollama if AI is requested
    ollama = false
    mistral_api_key = "api_key"
    if use_ai
        ollama = get_user_input("\033[1m🖥️  Use local Ollama instead of Mistral API?\033[0m (y/n): ", ["y", "yes", "n", "no"])
         if !ollama
            print("\033[1m🔑 Enter Mistral API key\033[0m (press Enter to skip): ")
            input_key = readline()
            if !isempty(input_key)
               global mistral_api_key = input_key
            end
        end
    end

    clear_keep_banner()
    # Data status section
    println("\n\033[1;36m📊 Current Database Status\033[0m")
    println("═══════════════════")
    if isfile(ssrn_path)
        existing_ssrn = CSV.read(ssrn_path, DataFrame)
        println("\033[1m📚 SSRN Database:\033[0m $(nrow(existing_ssrn)) rows")
    else
        println("\033[1m📚 SSRN Database:\033[0m Not found")
    end

    if isfile(afa_path)
        existing_afa = CSV.read(afa_path, DataFrame)
        println("\033[1m🏛️  AFA Database:\033[0m  $(nrow(existing_afa)) rows")
    else
        println("\033[1m🏛️  AFA Database:\033[0m  Not found")
    end

    clear_keep_banner()
    # Scraping section
    println("\n\033[1;36m🔄 Updating Databases\033[0m")
    println("══════════════════")
    println("\033[1m📥 Retrieving SSRN postings...\033[0m")
    new_ssrn = ssrn_jobs()
    println("  └─ Found $(nrow(new_ssrn)) new entries")
    
    # Initialize ssrn_table with existing data
    if isfile(ssrn_path)
        ssrn_table = CSV.read(ssrn_path, DataFrame)
        println("   └─ Loaded \033[1m$(nrow(ssrn_table))\033[0m existing entries")
        ssrn_table[!, :old] .= 1
    else
        ssrn_table = DataFrame()
    end
    
    # Process and append new SSRN data if any exists
    if !isempty(new_ssrn)
        println("   └─ Processing new entries...")
        new_ssrn.Html = clean_ssrn_html.(new_ssrn.Html)
        new_ssrn.Html = get_text_only.(new_ssrn.Html)
        new_ssrn[!, :timestamp] = fill(Dates.now(), nrow(new_ssrn))
        new_ssrn[!, :old] = zeros(Int, nrow(new_ssrn))
        new_ssrn[!, :used_ai] = zeros(Int, nrow(new_ssrn))
        
        # Append new data to existing
        if !isempty(ssrn_table)
            ssrn_table = vcat(new_ssrn, ssrn_table)
        else
            ssrn_table = new_ssrn
        end
        
        # Save updated data
        CSV.write(ssrn_path, ssrn_table)
    end
    
    # Retrieve and process AFA jobs
    println("\n\033[1m📥 Retrieving AFA postings...\033[0m")
    new_afa = afa_jobs()
    println("   └─ Found $(nrow(new_afa)) new entries")
    
    # Initialize afa_table with existing data
    if isfile(afa_path)
        afa_table = CSV.read(afa_path, DataFrame)
        println("   └─ Loaded \033[1m$(nrow(afa_table))\033[0m existing entries")
        afa_table[!, :old] .= 1
    else
        afa_table = DataFrame()
    end
    
    # Process and append new AFA data if any exists
    if !isempty(new_afa)
        println("   └─ Processing new entries...")
        # Add new columns as vectors rather than trying to assign directly
        new_afa[!, :timestamp] = fill(Dates.now(), nrow(new_afa))
        new_afa[!, :old] = zeros(Int, nrow(new_afa))
        new_afa[!, :used_ai] = zeros(Int, nrow(new_afa))
        
        # Append new data to existing
        if !isempty(afa_table)
            afa_table = vcat(new_afa, afa_table)
        else
            afa_table = new_afa
        end
        
        # Save updated data
        CSV.write(afa_path, afa_table)
    end
    clear_keep_banner()
    # Process with AI if requested and possible
    if use_ai
        println("\n\033[1;36m🤖 AI Processing\033[0m")
        println("═════════════")
        if ollama
            println("📡 Using local Ollama")
        elseif isequal(mistral_api_key, "api_key")
            println("\033[1;31m⚠️  Warning: No API key provided - skipping AI processing\033[0m")
            use_ai = false
        else
            println("☁️  Using Mistral API")
        end
        
        # Initialize AI results
        ssrn_ai_results = isfile(ssrn_ai_path) ? CSV.read(ssrn_ai_path, DataFrame) : DataFrame()
        afa_ai_results = isfile(afa_ai_path) ? CSV.read(afa_ai_path, DataFrame) : DataFrame()
        
        # Process new unprocessed SSRN entries
        new_unprocessed_ssrn = filter(row -> row.old == 0 && row.used_ai == 0, ssrn_table)
        if !isempty(new_unprocessed_ssrn)
            println("   └─ Processing \033[1m$(nrow(new_unprocessed_ssrn))\033[0m SSRN entries with AI...")
            ssrn_ai_new = process_html_batch(string.(new_unprocessed_ssrn.Html); ollama=ollama)
            ssrn_ai_new[!, :Html] = new_unprocessed_ssrn.Html
            
            # Update AI flag for processed entries
            for html in new_unprocessed_ssrn.Html
                rows = findall(==(html), ssrn_table.Html)
                ssrn_table[rows, :used_ai] .= 1
            end
            
            # Update AI results
            if !isempty(ssrn_ai_results)
                ssrn_ai_results = vcat(ssrn_ai_new, ssrn_ai_results)
            else
                ssrn_ai_results = ssrn_ai_new
            end
            
            # Save updated data
            CSV.write(ssrn_path, ssrn_table)
            CSV.write(ssrn_ai_path, ssrn_ai_results)
        end
        
        # Process new unprocessed AFA entries
        new_unprocessed_afa = filter(row -> row.old == 0 && row.used_ai == 0, afa_table)
        if !isempty(new_unprocessed_afa)
            println("   └─ Processing \033[1m$(nrow(new_unprocessed_afa))\033[0m AFA entries with AI...")
            afa_ai_new = process_html_batch(string.(new_unprocessed_afa.Description); ollama=ollama)
            afa_ai_new[!, :Description] = new_unprocessed_afa.Description
            
            # Update AI flag for processed entries
            for desc in new_unprocessed_afa.Description
                rows = findall(==(desc), afa_table.Description)
                afa_table[rows, :used_ai] .= 1
            end
            
            # Update AI results
            if !isempty(afa_ai_results)
                afa_ai_results = vcat(afa_ai_new, afa_ai_results)
            else
                afa_ai_results = afa_ai_new
            end
            
            # Save updated data
            CSV.write(afa_path, afa_table)
            CSV.write(afa_ai_path, afa_ai_results)
        end
    end
    
    clear_keep_banner()
    # Prepare and save final output using all AI results
    println("\n\033[1;36m📊 Final Status\033[0m")
    println("════════════")
    final_output = prepare_final_output(
        ssrn_table, 
        afa_table,
        use_ai,
        use_ai ? ssrn_ai_results : nothing, 
        use_ai ? afa_ai_results : nothing
    )


    # Define expected columns
    expected_columns = [
        :Deadline, :AFADeadline, :Organisation, :Title, :Location,
        :App_link, :App_email, :Required_Docs, :Other_Docs, :Summary,
        :App_JobID, :source, :Link, :timestamp
    ]

    # Check which columns exist
    available_columns = Symbol[]
    missing_columns = Symbol[]
    
    for col in expected_columns
        if hasproperty(final_output, col)
            push!(available_columns, col)
        else
            push!(missing_columns, col)
        end
    end


    # Only proceed with column selection if we have data
    if !isempty(final_output) && !isempty(available_columns)
        select!(final_output, available_columns)
    else
        println("\n\033[1;31m⚠️  Warning: Data validation failed\033[0m")
        println("   └─ Empty output: $(isempty(final_output))")
        println("   └─ No columns: $(isempty(available_columns))")
    end

    # Save final output
    if !isempty(final_output)
        file_path_out = replace(output_path,"Jobs.csv"=>replace("$(Dates.today())_Jobs.csv", "-"=>""))
        CSV.write(file_path_out, final_output)
        println("\n\033[1;32m✅ Successfully saved $(nrow(final_output)) entries\033[0m")
        println("   📁 Output: $file_path_out")
    else
        println("\n\033[1;31m❌ Warning: No data to save!\033[0m")
    end
end
end # Module

using .FinJobScraper
try
    main()
    println("\n\033[1;33m Press Enter to exit...\033[0m")
    readline()
catch e
    println("\n\033[1;31m❌ An error occurred:\033[0m")
    println(e)
    println("\n\033[1;31mStacktrace:\033[0m")
    for (exc, bt) in Base.catch_stack()
        showerror(stdout, exc, bt)
        println()
    end
    println("\n\033[1;33m Press Enter to exit...\033[0m")
    readline()
end