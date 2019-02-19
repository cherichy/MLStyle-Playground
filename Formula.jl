using StatsModels,DataFrames,MLStyle
include("Chain.jl")

data = DataFrame(A=[1,2,3], B=[2,4,7],C=[1,3,2],D=[3,2,5])

function form(expr)
    @match expr begin
        :($var~$data-$drop)=>
            let res=@chain propertynames(eval(data)).filter(i->i!=var&&i!=drop).join('+')
                :(@formula($var~$(Meta.parse(res))))
            end
        :($var~$data)=>
            let res=@chain propertynames(eval(data)).filter(i->i!=var).join('+')
                :(@formula($var~$(Meta.parse(res))))
            end
    end
end

macro form(expr)
    form(expr)|>esc
end


@info @form(A~data)==@formula(A~B+C+D)
@info @form(A~data-B)==@formula(A~C+D)
