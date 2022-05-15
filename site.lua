return {
    cssComment = {
        ["/%*.-%*/"] = "\n";
    };
    jsComment = {
        ["//.*\n"] = "\n";
        ["/%*.-%*/"] = "";
    };
    rooturl = "https://qwreey75.github.io/";
    links = [[
<div id="linkspace">
<div id="linkspace_github">

</div>
</div>
<style>
#linkspace {
}
</style>
]];
    owner = {
        name = "쿼리";
        engname = "qwreey";
    };
    sitemap_templates = {
        selected = table.concat{
            '<a herf="/{#:url:#}">';
                '<div class="selected">';
                    '<p class="selected">{#:title:#}</p>';
                '</div>';
            '</a>'
        };
        collapsible = table.concat{
            '<a herf="/{#:url:#}">';
            '<div class="collapsible">';
            '</a>';
        };
        collapsible_selected = table.concat{

        };
    };
    sitemap_listed = {
        {
            name = "Home";
            ref = "index.html";
        };
        {
            name = "School";
            {
                name = "Studygroup";
                ref = "studygroup/index.md";
            };
        };
    };
};
