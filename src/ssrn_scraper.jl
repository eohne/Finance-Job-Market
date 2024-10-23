const SSRN = "https://www.ssrn.com/index.cfm/en/janda/job-openings/?jobsNet=203";
const months = ["1", "01", "January", "Jan",
    "2", "02", "February", "Feb", "3", "03", "March", "Mar", "4", "04", "April", "Apr",
    "5", "05", "May", "6", "06", "June", "Jun", "7", "07", "July", "Jul", "8", "08", "August", "Aug", "9", "09", "September", "Sep",
    "10", "October", "Oct", "11", "November", "Nov", "12", "December", "Dec"];

const d_str = "\\d{1,2}";
const filler_str = "(\\|/| |, |-)";
const y_str = "\\d{4}";

const regex = Regex(join(vcat(months .* filler_str .* d_str .* filler_str .* y_str,
        y_str .* filler_str .* months .* filler_str .* d_str,
        d_str .* filler_str .* months .* filler_str .* y_str), "|")
);
function get_text(x::AbstractString)
    return Gumbo.parsehtml(x).root |> text
end;
function get_link(x::AbstractString)
    m = match(r"""<a href.*\\\">""", x).match
    return replace(m, r"(<a href=\\\"|.>$)" => "")
end;

function clean_ssrn_html(raw_html)
    temp = split(raw_html,"\n")
    start_idx = findfirst(x->occursin(r"\<div class=\"maincontent \"\>",x), temp)
    end_idx = findfirst(x->occursin(r"\</article\>",x), temp)
    return join(temp[start_idx:end_idx],"\n")
end

function get_application_procedure(link)
    resp2 = HTTP.request("GET", link, retry=true, retry_delays=ExponentialBackOff(n=10, first_delay=0.15)).body |> String
    html_text = resp2
    dates = [i.match for i in eachmatch(regex, resp2)]
    if isempty(dates)
        dates = ""
    else
        dates = join(dates[2:end], ", ")
    end
    resp2 = split(resp2, "\n")
    idx = findall(x -> occursin.("<h3>Application Procedure", x), resp2)
    if isempty(idx)
        return "", dates, html_text
    else
        idx = idx[1] + 1
    end
    return text(parsehtml(resp2[idx]).root), dates, clean_ssrn_html(html_text)
end;
function ssrn_jobs()
    resp = HTTP.get(SSRN)
    resp = String(resp.body)
    resp = split(resp, "\n")
    jt_idx = findall(x -> occursin.("job-title-link", x), resp)
    jd_idx = findall(x -> occursin.("job-date", x), resp)
    jorg_idx = findall(x -> occursin.("job-org-name", x), resp)
    jl_idx = findall(x -> occursin.("gizmo-location", x), resp)

    jlink = get_link.(resp[jt_idx])
    jt = get_text.(resp[jt_idx])
    jd = get_text.(resp[jd_idx])
    jorg = get_text.(resp[jorg_idx])
    jl = get_text.(resp[jl_idx])
    res = DataFrame(Posted=jd, Organisation=jorg, Title=jt, Location=jl, Link=jlink)

    # Load already complete:
    if isfile(ssrn_path)
        old_file = CSV.File(ssrn_path) |> DataFrame
        idx_keep = .!in.(res.Link, Ref(old_file.Link))
    else
        idx_keep = [true for _ in 1:size(res, 1)]
    end
    res = res[idx_keep, :]
    ap_text = similar(res.Link)
    ap_dates = similar(res.Link)
    ap_raw_html = similar(res.Link)
    # Do this only for companies not yet in the list
    @showprogress for i in 1:nrow(res)
            ap_text[i], ap_dates[i], ap_raw_html[i] = try
            get_application_procedure(res.Link[i])
        catch e
            print("\nError with item: $i\n")
            "","",""
        end
    end
    res.Description = ap_text
    res.Deadline = ap_dates
    res.Html = ap_raw_html
    return res
end;