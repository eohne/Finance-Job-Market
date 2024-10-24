tpl= PromptingTools.create_template("You are a JSON extractor that MUST:
1. Keep ApplicationID inside the Apply object
2. Convert ALL document names to standard formats
3. Return only valid JSON
4. Never add explanatory text", 
"""
Convert job posting information to this EXACT structure:
{
    "Deadline": "yyyy-mm-dd",
    "Apply": {
        "Link": "url", \\This should be the link to the online application
        "Email": "email",
        "ApplicationID": "application_id"
    },
    "RequiredDocuments": [
        // standardized names only
    ],
    "OtherDocuments": [
        // non-standard documents
    ],
    "Summary": "application_summary" \\ Summary max 30 words
}

EXACT document conversions - if you see text like:
"vita/CV" → Use "Curriculum Vitae"
"letter of interest/cover letter" → Use "Cover Letter"
"research statement/plan" → Use "Research Statement"
"teaching evaluation/statement" → Use "Teaching Statement"
"publications/papers/writing samples" → Use "Job Market Paper/other papers"
"three references/3 references" → Use "References (3)"

Example:
Input: Submit (1) vita (2) letter of interest (3) publications if applicable (4) teaching evals (5) three references

Output:
{
    "Deadline": " ",
    "Apply": {
        "Link": " ",
        "Email": " ",
        "ApplicationID": " "
    },
    "RequiredDocuments": [
        "Curriculum Vitae",
        "Cover Letter",
        "Job Market Paper/other papers",
        "Teaching Statement",
        "References (3)"
    ],
    "OtherDocuments": [],
    "Summary": "This application is for this position and school. It is non-tenure track."
}

Parse this text:
{{text}}"""; load_as="EXTRACTJSONSSRN")

nothing_missing_to_space(x::Any) = x;
nothing_missing_to_space(x::Nothing) = " ";
nothing_missing_to_space(x::Missing) = " ";
function extract_ai_summary(raw_html::String; max_retries=5,ollama=true)
    # Create empty DataFrame with correct structure for fallback
    empty_df = DataFrame(
        Deadline = " ",
        App_link = " ",
        App_email = " ",
        App_JobID = " ",
        Required_Docs = " ",
        Other_Docs = " ",
        Summary = " ",
    )

    for attempt in 1:max_retries
        try
            # Generate AI response
            if ollama
                msg = aigenerate(PromptingTools.OllamaSchema(), tpl; text=raw_html, model="llama3.1") #mistral-nemo:latest
            else
                sleep(1)
                msg = aigenerate(PromptingTools.MistralOpenAISchema(),tpl,text=raw_html, model="mistral-medium", api_key=mistral_api_key)
            end
            # Parse JSON
            json = JSON3.read(msg.content)
            
            # Create DataFrame
            res = DataFrame(
                Deadline = json.Deadline |> nothing_missing_to_space, 
                App_link = json.Apply.Link |> nothing_missing_to_space, 
                App_email = json.Apply.Email |> nothing_missing_to_space,
                App_JobID = json.Apply.ApplicationID |> nothing_missing_to_space,
                Required_Docs = join(sort(json.RequiredDocuments), ", "),
                Other_Docs = join(json.OtherDocuments, ", "),
                Summary = json.Summary |> nothing_missing_to_space
            )
            
            return res

        catch e
            if attempt == max_retries
                @info "Failed to process after $max_retries attempts. Returning empty DataFrame."
                return empty_df
            else
                @info "Attempt $attempt failed. Retrying..."
            end
        end
    end
    
    return empty_df  # Fallback, should not reach here
end

function process_html_batch(raw_htmls::Vector{<:AbstractString}; max_retries=5, ollama=true)
    # Initialize empty result DataFrame
    results = DataFrame()
    
    # Setup progress meter
    p = Progress(length(raw_htmls); desc="\033[1;36m🤖 Processing entries      \033[0m", 
    barglyphs=BarGlyphs('|','█', ['▁' ,'▂' ,'▃' ,'▄' ,'▅' ,'▆', '▇'],' ','|',),
    barlen=40,
    # output=stderr,
    color=:cyan,
    showspeed=true)
    
    # Process each HTML string
    @suppress_out begin  # Suppresses stdout
        @suppress_err begin  # Suppresses stderr
            for html in raw_htmls
                df = extract_ai_summary(html; max_retries=max_retries,ollama=ollama)
                append!(results, df)
                next!(p)
            end
        end
    end
    
    return results
end