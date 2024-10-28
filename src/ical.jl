using Dates
using UUIDs
using CSV
using DataFrames


function manual_format_datetime(dt::DateTime)
    return "$(year(dt))$(lpad(month(dt), 2, '0'))$(lpad(day(dt), 2, '0'))T$(lpad(hour(dt), 2, '0'))$(lpad(minute(dt), 2, '0'))$(lpad(second(dt), 2, '0'))Z"
end




function create_ical_file(start_datetime::DateTime, end_datetime::DateTime, title::String, description::String)
    # Generate a unique identifier for the event
    uid = string(uuid4())

    # Format dates using our manual formatting function
    start_str = manual_format_datetime(start_datetime)
    end_str = manual_format_datetime(end_datetime)
    current_str = manual_format_datetime(now(UTC))

    # Create the iCalendar content
    vevent = """
    BEGIN:VEVENT
    CLASS:PUBLIC
    DESCRIPTION:$(description)
    DTEND:$(end_str)
    DTSTAMP:$(current_str)
    DTSTART:$(start_str)
    PRIORITY:5
    SEQUENCE:0
    SUMMARY;LANGUAGE=en-us:$(title)
    TRANSP:TRANSPARENT
    UID:$(uid)
    BEGIN:VALARM
    TRIGGER:PT0M
    ACTION:DISPLAY
    DESCRIPTION:Reminder
    END:VALARM
    END:VEVENT
    """
        return vevent
end

function ical(file_name,df::DataFrame)
    events = ""
    old_deadline = Date(1990,1,1)
    m = 0
    h=0
    for r in eachrow(df)
        if r.Deadline == old_deadline
            m +=10
            if m>49
                h+=1
                m=0
            end
        else
            m =0
            h=0
        end
        old_deadline=r.Deadline
        # desc = """Title:\t$(r.Title)\n\t\\nSource:\t$(r.Source)\n\t\\nLink:\t$(r.SSRNLink)"""
        desc = """Title:\t$(r.Title)\n\t\\nSource:\t$(r.Source)\n\t\\nLink:\t$(r.SSRNLink)\n\t\\nApp:\t$(r.App_link)\n\t\\nEmail:\t$(r.App_email)\n\t\\nDocs:\t$(r.Required_Docs)\n\t\\nOther:\t$(r.Other_Docs)\n\t\\nAI Summary:\t$(r.Summary)"""
        res = create_ical_file.(DateTime(year(r.Deadline),month(r.Deadline),day(r.Deadline),09+h,m,00), 
                                                            DateTime(year(r.Deadline),month(r.Deadline),day(r.Deadline),09+h,m+10,00),r.School,desc)
        events = join([events,res],"")
    end
vcal = """
BEGIN:VCALENDAR
PRODID:-//Julia/iCal Creator v1.0//EN
VERSION:2.0
NAME:Uni Applications
METHOD:PUBLISH
CALSCALE:GREGORIAN
$(events)END:VCALENDAR
"""
    write(file_name,vcal)
end


jobs = CSV.File("ical.csv") |> DataFrame;
rename!(jobs, names(jobs) .=> replace.(names(jobs), r"( ){1,}"=>"") );
subset!(jobs, :Deadline => x->(.!ismissing.(x)))
select!(jobs, :Deadline,:Source,:School,:SSRNLink,:Title,:App_link,:App_email,:Required_Docs,:Other_Docs,:Summary);
any_to_string(x::Any) = string(x);
transform!(jobs, [:Source,:School,:SSRNLink,:Title,:App_link,:App_email,:Required_Docs,:Other_Docs,:Summary] .=> ByRow(any_to_string),renamecols=false )
sort!(jobs, :Deadline)
ical("all_events.ics",jobs)
# max_counter was 50
