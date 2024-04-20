function move_examples_to_docs!(src_folder, dst_folder, start_pattern; remove_pattern=false)
    for (root, _, files) in walkdir(src_folder)
        for filename in filter(startswith(start_pattern), files)
            if !endswith(filename, ".jl")
                continue
            end
            if remove_pattern
                filename_gen = filename[(length(start_pattern) + 1):end] # removes "pluto-"
            else
                filename_gen = filename
            end
            cp(joinpath(root, filename), joinpath(dst_folder, filename_gen); force=true)
        end
    end
end

# Based on https://github.com/jump-dev/JuMP.jl/blob/master/docs/make.jl
# Add Literate links after the title
function _link_example(filename)
    function _link_example_for_filename(content)
        title_line = findfirst(r"\n# .+?\n", content)
        line = content[title_line]
        badges = """

        #md # [![](https://img.shields.io/badge/julia-script-9558B2?logo=julia)](./$filename.jl)
        #md # [![](https://img.shields.io/badge/jupyter-notebook-blue?logo=jupyter)](./$filename.ipynb)

        """
        return replace(content, line => line * badges)
    end
    return _link_example_for_filename
end

function list_md_not_lit(input_folder, output_doc_section; exclude="-----------------------", lit_start_pattern="lit-")
    md_list = String[]
    for (root, _, files) in walkdir(input_folder)
        for filename in filter(endswith(".md"), files)
            if startswith(lit_start_pattern, filename)
                continue
            end
            if occursin(exclude, filename)
                continue
            end
            push!(md_list, "$output_doc_section/$filename")
        end
    end
    return md_list
end

function literate_doc_folder(input_folder, output_doc_section; lit_start_pattern="lit-")
    tutorial_list = []
    for (root, _, files) in walkdir(input_folder)
        for filename in filter(startswith(lit_start_pattern), files)
            filename_gen = splitext(filename)[1][(length(lit_start_pattern) + 1):end] # removes "lit-"
            tutorial_src = joinpath(input_folder, filename)
            tutorial_md  = "$output_doc_section/$filename_gen.md"
            Literate.markdown(
                tutorial_src,
                input_folder;
                repo_root_url,
                preprocess=_link_example(filename_gen),
                name=filename_gen,
            )
            Literate.script(tutorial_src, input_folder; name=filename_gen, repo_root_url)
            Literate.notebook(tutorial_src, input_folder; name=filename_gen, execute=false)
            push!(tutorial_list, tutorial_md)
        end
    end
    return tutorial_list
end

# TODO: copy files with "pluto-" to docs, and remove for generated html and md
function pluto_directory_to_html(doc_tutorial_pluto, doc_output_section; pluto_start_pattern="pluto-")
    reproducible_list = String[]
    for (root, _, files) in walkdir(doc_tutorial_pluto)
        for filename in filter(endswith("jl"), files)
            # if !startswith(pluto_start_pattern, filename)
            #     continue
            # end
            filename_gen  = splitext(filename)[1]
            tutorial_src  = joinpath(doc_tutorial_pluto, filename)
            tutorial_md   = joinpath(doc_tutorial_pluto, "$filename_gen.md")
            # HTML to Markdown
            frontmatter = PlutoSliderServer.Pluto.frontmatter(tutorial_src)
            iframe = """
            # $(frontmatter["title"])

            ```@raw html
            <iframe type="text/html" src="../$filename_gen.html" style="height:100vh;width:100%;"></iframe>
            ```
            """
            open(tutorial_md, "w") do file
                write(file, iframe)
            end
            push!(reproducible_list, "$doc_output_section/$filename_gen.md")
        end
    end
    PlutoSliderServer.export_directory(doc_tutorial_pluto)
    return reproducible_list
end
