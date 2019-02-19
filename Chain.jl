using MLStyle

"""
Rename from Linq.jl. Chain.jl can be used for any function (including lambdas) while Linq.jl uses dispatch (require define dispatch function for Hygiene).
"""
module Chain
    map(arr, f) = Base.map(f, arr)

    filter(arr, f) = Base.filter(f, arr)

    collect(arr) = Base.collect(arr)
    collect(arr, ::Type{T}) where T = Base.collect(T, arr)

    flat_map(arr, f) = Base.vcat(Base.map(f, arr)...)

    skip(arr) = Base.view(arr, 2:Base.length(arr))
    skip(arr, n) = Base.view(arr, n:Base.length(arr))

    len(arr) = Base.length(arr)

    drop(arr, n) = Base.view(arr, 1:(Base.length(arr) - n))

    sum(arr, f) = Base.sum(f, arr)
    sum(arr, dim::Int) = Base.sum(arr,dims=dim)
    sum(arr) = Base.sum(arr)

    group_by(arr, f) = begin
        result = OrderedDict()
        for elt in arr
            push!(get!(result, f(elt)) do
                    []
                  end,
                  elt)
        end
        result
    end

    group_by(arr) = begin
        result = OrderedDict()
        for elt in arr
            push!(get!(result, elt) do
                    []
                  end,
                  elt)
        end
        result
    end

    any(arr, f) = Base.any(f, arr)
    any(arr) = Base.any(arr)

    all(arr, f) = Base.all(f, arr)
    all(arr) = Base.all(arr)

    enum(arr) = enumerate(arr)

    foldl(arr, f) = Base.foldl(f, arr)
    foldl(arr, f, init) = Base.foldl(f, arr, init=init)

    foldr(arr, f) = Base.foldr(f, arr)
    foldr(arr, f, init) = Base.foldr(f, arr, init=init)

    sort(arr) = Base.sort(arr)
    sort(arr, f) = Base.sort(arr, by=f)

end

# a.f(args...)->f(a,args...)
# a.f.(aegs...)->f.(a,args...)
# a.(lambda)->lambda(a)

function chain(expr)
    @match expr begin
        :($subject.$method.($(args...))) =>
            let subject = chain(subject)
                if isdefined(Chain, method)
                    let method = getfield(Chain, method)
                        :($method.($subject, $(args...)))
                    end
                else
                    :($method.($subject, $(args...)))
                end
            end
        :($subject.$method($(args...))) =>
            let subject = chain(subject)
                if isdefined(Chain, method)
                    let method = getfield(Chain, method)
                        :($method($subject, $(args...)))
                    end
                else
                    :($method($subject, $(args...)))
                end
            end
        :($subject.($lambda)) =>
            let subject = chain(subject)
                :(($lambda)($subject))
            end
        _ => expr
    end
end

macro chain(expr)
    esc(chain(expr))
end


@chain (1:10).map(x -> 2x).filter(x->x>7).sum()


