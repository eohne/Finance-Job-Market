# set dir location:
cd(@__DIR__)
const afa_url = "https://careers.afajof.org/job/";
get_job_url(id) = afa_url * string(id);

function get_job(id)
    resp = HTTP.get(get_job_url(id)).body |> String
    resp = split(resp, "\n")
    idx_start = findfirst(x -> occursin(""""http://schema.org""", x), resp) - 1
    idx_end = findfirst(x -> occursin("</script>", x), resp[idx_start:end]) + idx_start - 2
    json = join(resp[idx_start:idx_end], "\n")
    json = JSON3.read(json)
    title = json.title
    desc = json.description
    deadline = json.validThrough
    org = json.hiringOrganization.name
    loc = json.jobLocation[1].address |> values |> collect |> x -> join(x[2:end], ", ")
    return title, desc, deadline, org, loc
end

function get_afa_ids(max_n=100)
    all_ids = String[]
    i = 1
    for i in 1:max_n
        ids = HTTP.get("https://careers.afajof.org/jobs/" * string(i, "/"))
        ids = ids.body |> String
        ids = split(ids, "\n")
        check_idx = findfirst(x -> occursin("""<title> Browse jobs | AFA Careers in Finance and Economics | page """, x), ids)
        if !isnothing(check_idx) && i > parse(Int, match.(r"[0-9]{1,}", ids[check_idx]).match)
            break
        end
        idx = findall(x -> occursin("""<input type="hidden" name="JobId" value=""", x), ids)
        ids = [String(match(r"[0-9]{6}", i).match) for i in ids[idx]]
        append!(all_ids, ids)
    end
    return all_ids
end


function afa_jobs()
    afa_ids = get_afa_ids()

    # Only load jobs that are not loaded already:
    # Load already complete:
    if isfile(afa_path)
        old_file = CSV.File(afa_path) |> DataFrame
        idx_keep = .!in.(afa_url .* afa_ids, Ref(skipmissing(old_file.Link)))
    else
        idx_keep = [true for _ in 1:size(afa_ids, 1)]
    end
    afa_ids = afa_ids[idx_keep]
    #
    if all(.!(idx_keep))
        return DataFrame()
    end
        title = Vector{String}(undef, size(afa_ids, 1))
        desc = Vector{String}(undef, size(afa_ids, 1))
        deadline = Vector{String}(undef, size(afa_ids, 1))
        org = Vector{String}(undef, size(afa_ids, 1))
        loc = Vector{String}(undef, size(afa_ids, 1))

        for i in 1:size(afa_ids, 1)
            title[i], desc[i], deadline[i], org[i], loc[i] = get_job(afa_ids[i])
        end


    AFA_Data = DataFrame(Title=title, Description=desc, Deadline=deadline, Organisation=org, Location=loc)
    transform!(AFA_Data, :Deadline => ByRow(x -> Date(x[begin:10]) - Day(1)), renamecols=false)
    AFA_Data[!, :Link] = afa_url .* afa_ids
    select!(AFA_Data, :Deadline, :Organisation, :Title, :Location, :Link, :Description)
    return AFA_Data
end

