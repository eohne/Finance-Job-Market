function install_dep(x::String...)
    print("\nChecking if all Package Dependencies are installed:\n")
    inst_pack = [i.name for i in values(Pkg.dependencies())]
    for pkg in x
        if pkg ∈ inst_pack
            print("\r                                                    ")
            nothing
        else
            print("\rInstalling: $pkg")
            Pkg.add(pkg)
        end
    end
    print("\rAll packages successfully installed!\n")
    return nothing
end;