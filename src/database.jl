"""
Saves a global timestamp for a new run, so that all results from this run have the
same time stamp
"""
function new_run()
    open(joinpath(@__DIR__, "global_timestemp.jls"), "w") do io
        serialize(io, now())
    end
end

"""
Queries the time stamp of the last run
"""
function last_time_stamp()
    open(joinpath(@__DIR__, "global_timestemp.jls")) do io
        deserialize(io)
    end
end
"""
Database schema.
"""
immutable BenchResult
    name::String
    benchmark::BenchmarkTools.Trial
    N::Int
    typ::DataType
    device::String
    hardware::String
    codepath::String
    meandiffrence::Float64
    timestamp::DateTime
end

function Base.show(io::IO, b::BenchResult)
    println(io, "BenchResult:")
    println(io, "    ", b.name)
    print(io, "    ")
    show(io, b.benchmark)
    println(io)
    println(io, "    device: ", b.device)
    println(io, "    hardware: ", b.hardware)
    println(io, "    meandiff: ", b.meandiffrence)
    println(io, "    time: ", b.timestamp)
end


function BenchResult(
        x::BenchResult;
        name = x.name,
        benchmark = x.benchmark,
        N = x.N,
        typ = x.typ,
        device = x.device,
        hardware = x.hardware,
        codepath = x.codepath,
        meandiffrence = x.meandiffrence
    )
    BenchResult(
        name,
        benchmark,
        N,
        typ,
        device,
        hardware,
        codepath,
        meandiffrence
    )
end


function BenchResult(
        name::String,
        benchmark::BenchmarkTools.Trial,
        N::Int,
        typ::DataType,
        device::String,
        hardware::String,
        codepath::String,
        meandiff
    )
    BenchResult(
        name,
        benchmark,
        N,
        typ,
        device,
        hardware,
        codepath,
        meandiff,
        last_time_stamp()
    )
end

for field in fieldnames(BenchResult)
    constr_expr = Expr(:call, BenchResult)
    for field2 in fieldnames(BenchResult)
        if field2 == field
            push!(constr_expr.args, :(cval))
        else
            push!(constr_expr.args, :(x.$(field2)))
        end
    end
    @eval begin
        $field(x::BenchResult) = x.$field
        function $field(x::BenchResult, val)
            cval = convert($(fieldtype(BenchResult, field)), val)
            $constr_expr
        end
    end
end

const database_path = joinpath(@__DIR__, "..", "results", "data", "database.jld2")

get_database() = load(database_path)["database"]
update_database!(data::Vector{BenchResult}) = save(database_path, Dict("database" => data))

function append_data!(results::Vector{BenchResult})
    db = get_database()
    append!(db, results)
    update_database!(db)
    return
end
