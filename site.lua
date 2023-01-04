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
            '<div class="uncollapsible notSelected">';
                '<a href="/{#:url:#}">';
                    '<p>{#:title:#}</p>';
                '</a>';
            '</div>';
            '{#:next:#}';
        },"\n");
        normal_nourl = table.concat({
            '<div class="uncollapsible notSelected">';
                '<p>{#:title:#}</p>';
            '</div>';
            '{#:next:#}';
        },"\n");
        normal_selected = table.concat({
            '<div class="uncollapsible selected">';
                '<a href="/{#:url:#}">';
                    '<p>{#:title:#}</p>';
                '</a>';
            '</div>';
            '{#:next:#}';
        },"\n");
        normal_selected_nourl = table.concat({
            '<div class="uncollapsible selected">';
                '<p>{#:title:#}</p>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible = table.concat({
            '<div class="collapsible collapsed">';
                '<div class="collapseButton notSelected">';
                    '<a href="/{#:url:#}">';
                        '<p>{#:title:#}</p>';
                    '</a>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_open = table.concat({
            '<div class="collapsible">';
                '<div class="collapseButton notSelected">';
                    '<a href="/{#:url:#}">';
                        '<p>{#:title:#}</p>';
                    '</a>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_nourl = table.concat({
            '<div class="collapsible collapsed">';
                '<div class="collapseButton notSelected">';
                    '<p>{#:title:#}</p>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_nourl_open = table.concat({
            '<div class="collapsible">';
                '<div class="collapseButton notSelected">';
                    '<p>{#:title:#}</p>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected = table.concat({
            '<div class="collapsible collapsed">';
                '<div class="collapseButton selected">';
                    '<a href="/{#:url:#}">';
                        '<p>{#:title:#}</p>';
                    '</a>';
                '</div>';
                '<div class="children" style="maxHeight: 0px">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected_open = table.concat({
            '<div class="collapsible">';
                '<div class="collapseButton selected">';
                    '<a href="/{#:url:#}">';
                        '<p>{#:title:#}</p>';
                    '</a>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected_nourl = table.concat({
            '<div class="collapsible collapsed">';
                '<div class="collapseButton selected">';
                    '<p>{#:title:#}</p>';
                '</div>';
                '<div class="children" style="maxHeight: 0px">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
        collapsible_selected_nourl_open = table.concat({
            '<div class="collapsible">';
                '<div class="collapseButton selected">';
                    '<p>{#:title:#}</p>';
                '</div>';
                '<div class="children">';
                    '<div class="childrenHolder">{#:child:#}</div>';
                '</div>';
            '</div>';
            '{#:next:#}';
        },"\n");
    };
    sitemap_list = {
        {
            name = "홈";
            ref = "index";
        };
        {
            name = "교내활동";
            {
                name = "바탕화면 급식표 프로그램";
                ref = "mealswidget";
            };
            {
                name = "(망함) 테마 변경 방지 프로그램";
                ref = "dontChangeMyTheme";
            };
        };
        {
            name = "라이브러리 라이선스";
            ref = "deps";
        };
    };
};
