const PT = PromptingTools;

function clean_ssrn_html(raw_html)
    temp = split(raw_html,"\n")
    start_idx = findfirst(x->occursin(r"\</header1\>",x), temp)
    end_idx = findfirst(x->occursin(r"\</article\>",x), temp)
    return join(temp[start_idx:end_idx],"\n")
end

tpl=PT.create_template("You are a JSON extractor that MUST:
1. Keep ApplicationID inside the Apply object
2. Convert ALL document names to standard formats
3. Return only valid JSON
4. Never add explanatory text", 
"""Convert job posting information to this EXACT structure:
{
    "Deadline": "yyyy-mm-dd",
    "Apply": {
        "Link": "url",
        "Email": "email",
        "ApplicationID": "application_id"
    },
    "RequiredDocuments": [
        // standardized names only
    ],
    "OtherDocuments": [
        // non-standard documents
    ]
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
    "OtherDocuments": []
}

Parse this text:
{{text}}"""; load_as="EXTRACTJSONSSRN")


function extract_ai_summary(raw_html::String; max_retries=5,ollama=true)
    # Create empty DataFrame with correct structure for fallback
    empty_df = DataFrame(
        Deadline = " ",
        App_link = " ",
        App_email = " ",
        App_JobID = " ",
        Required_Docs = " ",
        Other_Docs = " "
    )

    for attempt in 1:max_retries
        try
            # Generate AI response
            if ollama
                msg = aigenerate(PT.OllamaSchema(), tpl; text=clean_ssrn_html(raw_html), model="mistral-nemo:latest")
            else
                sleep(1)
                msg = aigenerate(PT.MistralOpenAISchema(),tpl,text=clean_ssrn_html(raw_html), model="mistral-medium", api_key=mistral_api_key)
            end
            # Parse JSON
            json = JSON3.read(msg.content)
            
            # Create DataFrame
            res = DataFrame(
                Deadline = json.Deadline, 
                App_link = json.Apply.Link, 
                App_email = json.Apply.Email,
                App_JobID = json.Apply.JobID,
                Required_Docs = join(sort(json.RequiredDocuments), ", "),
                Other_Docs = join(json.OtherDocuments, ", ")
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


function process_html_batch(raw_htmls::Vector{String}; max_retries=5, ollama=true)
    # Initialize empty result DataFrame
    results = DataFrame()
    
    # Setup progress meter
    p = Progress(length(raw_htmls); desc="Processing job postings: ", 
                showspeed=true, barglyphs=BarGlyphs("[=> ]"))
    
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