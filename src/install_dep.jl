using Pkg
function install_dep(x::String...)
    print("\n Checking if all Package Dependencies are installed:")
    inst_pack = [i.name for i in values(Pkg.dependencies())]
    for pkg in x
        if pkg ∈ inst_pack
            print("\r                                 ")
            nothing
        else
            print("\rInstalling: $pkg")
            Pkg.add(pkg)
        end
    end
    eval(Meta.parse("""using $(join(x,","))"""))
    print("\rAll packages successfully installed and loaded!\n")
    return nothing
end;