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
        normal = table.concat({
            '<a herf="/{#:url:#}">';
                '<div class="notSelected">';
                    '<p>{#:title:#}</p>';
                '</div>';
            '</a>';
            '{#:next:#}';
        },"\n");
        normal_selected = table.concat({
            '<a herf="/{#:url:#}">';
                '<div class="selected">';
                    '<p>{#:title:#}</p>';
                '</div>';
            '</a>';
            '{#:next:#}';
        },"\n");
        collapsible = table.concat({
            '<div class="collapsible collapsed">';
                '<a herf="/{#:url:#}">';
                    '<div class="notSelected">';
                        '<p>{#:title:#}</p>';
                    '</div>';
                '</a>';
            '</div>';
            '<div>';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_open = table.concat({
            '<div class="collapsible">';
            '<a herf="/{#:url:#}">';
                    '<div class="notSelected">';
                        '<p>{#:title:#}</p>';
                    '</div>';
                '</a>';
            '</div>';
            '<div>';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_nourl = table.concat({
            '<div class="collapsible collapsed">';
                '<div class="notSelected">';
                    '<p>{#:title:#}</p>';
                '</div>';
            '</div>';
            '<div>';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_nourl_open = table.concat({
            '<div class="collapsible">';
                '<div class="notSelected">';
                    '<p>{#:title:#}</p>';
                '</div>';
            '</div>';
            '<div>';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected = table.concat({
            '<div class="collapsible collapsed">';
                '<a herf="/{#:url:#}">';
                    '<div class="selected">';
                        '<p>{#:title:#}</p>';
                    '</div>';
                '</a>';
            '</div>';
            '<div style="maxHeight: 0px">';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected_open = table.concat({
            '<div class="collapsible">';
                '<a herf="/{#:url:#}">';
                    '<div class="selected">';
                        '<p>{#:title:#}</p>';
                    '</div>';
                '</a>';
            '</div>';
            '<div>';
                '{":child:"}';
            '</div>';
            '{#:next:#}';
        },"\n");
    };
    sitemap_list = {
        {
            name = "Home";
            ref = "index";
        };
        {
            name = "School";
            {
                name = "Studygroup";
                ref = "studygroup/index";
            };
        };
    };
};
