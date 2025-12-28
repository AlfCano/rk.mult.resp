local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.mult.resp",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin package for analyzing multiple response sets. Includes expss analysis and raw count pivoting.",
      version = "0.0.4", # Frozen
      url = "https://github.com/AlfCano/rk.mult.resp",
      license = "GPL (>= 3)"
    )
  )

  common_hierarchy <- list("analysis", "Multiple Response (expss)")

  # =========================================================================================
  # 2. JS Helper
  # =========================================================================================
  js_parse_helper <- "
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        var df = '';
        var raw_col = '';
        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/[\"']/g, '');
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return { df: df, col: '\\\"' + raw_col + '\\\"', raw_col: raw_col };
    }

    function generateLabelingCode(varList) {
        var code = '';
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             code += 'lbl <- rk.get.label(' + varList[i] + ')\\n';
             code += 'if(is.null(lbl) || lbl == \"\") lbl <- \"' + p.raw_col + '\"\\n';
             code += 'expss::var_lab(df_temp[[' + p.col + ']]) <- lbl\\n';
        }
        return code;
    }
  "

  # =========================================================================================
  # COMPONENT 1: Define Variable Set
  # =========================================================================================
  help_define <- rk.rkh.doc(title = rk.rkh.title("Define Multiple Response Set"), summary = rk.rkh.summary("Define a set for expss."), usage = rk.rkh.usage("Select variables."))
  def_selector <- rk.XML.varselector(id.name = "def_selector")
  def_vars <- rk.XML.varslot(label = "Variables in Set", source = "def_selector", multi = TRUE, required = TRUE, id.name = "def_vars")
  def_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies (Counted value)" = list(val = "dichotomy", chk = TRUE), "Categories (Multiple columns)" = list(val = "category")), id.name = "def_type")
  def_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "def_counted_val")
  def_label <- rk.XML.input(label = "Set Label", initial = "My Response Set", id.name = "def_label")
  def_weight <- rk.XML.varslot(label = "Weight (Preview)", source = "def_selector", classes = "numeric", id.name = "def_weight")
  def_save <- rk.XML.saveobj(label = "Save Set as", chk = TRUE, initial = "my_mrset", id.name = "def_save_obj")
  def_preview <- rk.XML.preview(mode = "data")
  dialog_define <- rk.XML.dialog(label = "Define Multiple Response Set", child = rk.XML.row(def_selector, rk.XML.col(def_vars, rk.XML.frame(def_type, def_counted_val, def_label, label = "Definition"), def_weight, def_save, def_preview)))

  js_body_define <- paste0(js_parse_helper, '
    var vars = getValue("def_vars"); var type = getValue("def_type"); var val = getValue("def_counted_val"); var lbl = getValue("def_label"); var weight = getValue("def_weight");
    var varList = vars.split("\\n"); var colList = []; var dfName = "";
    for (var i = 0; i < varList.length; i++) { var p = parseVar(varList[i]); if (i === 0) dfName = p.df; colList.push(p.raw_col); }
    var cols_str = "c(\\\"" + colList.join("\\\", \\\"") + "\\\")";
    echo("df_temp <- " + dfName + "[, " + cols_str + "]\\n");
    echo(generateLabelingCode(varList));
    var mrset_cmd = "";
    if (type == "dichotomy") {
        var val_arg = val;
        if (isNaN(val)) { if (val.indexOf("$") > -1 || val.indexOf("[[") > -1) { val_arg = val; } else { val_arg = "\\\"" + val + "\\\""; } }
        echo("# Transforming dichotomies to labeled categories for display\\n");
        echo("for (col in names(df_temp)) { l <- expss::var_lab(df_temp[[col]]); df_temp[[col]] <- ifelse(df_temp[[col]] == " + val_arg + ", l, NA) }\\n");
        mrset_cmd = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
    } else {
        mrset_cmd = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
    }
  ')
  js_calc_define <- paste0(js_body_define, 'echo("my_mrset <- " + mrset_cmd + "\\n");')
  js_preview_define <- paste0(js_body_define, 'echo("temp_mrset <- " + mrset_cmd + "\\n"); if (weight != "") { echo("preview_data <- expss::fre(temp_mrset, weight = " + weight + ")\\n"); } else { echo("preview_data <- expss::fre(temp_mrset)\\n"); }')
  js_print_define <- 'var save_name = getValue("def_save_obj.objectname"); echo("rk.header(\\"Multiple Response Set Defined: " + save_name + "\\", level=3);\\n");'
  component_define <- rk.plugin.component("Define Variable Set", xml = list(dialog = dialog_define), js = list(require="expss", calculate = js_calc_define, preview = js_preview_define, printout = js_print_define), hierarchy = common_hierarchy, rkh = list(help = help_define))

  # =========================================================================================
  # COMPONENT 2: Frequencies (expss)
  # =========================================================================================
  help_freq <- rk.rkh.doc(title = rk.rkh.title("Multiple Response Frequencies"), summary = rk.rkh.summary("Calculate counts and percentages."), usage = rk.rkh.usage("Select set or variables."))
  freq_selector <- rk.XML.varselector(id.name = "freq_selector")
  freq_mode <- rk.XML.radio(label = "Data Source", options = list("Pre-defined Set" = list(val = "pre", chk = TRUE), "Define On-the-Fly" = list(val = "fly")), id.name = "freq_mode")
  freq_obj_slot <- rk.XML.varslot(label = "Select Set Object", source = "freq_selector", classes = c("dichotomy", "category", "data.frame"), id.name = "freq_obj_slot")
  freq_vars <- rk.XML.varslot(label = "Variables", source = "freq_selector", multi = TRUE, id.name = "freq_vars")
  freq_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies" = list(val = "dichotomy", chk = TRUE), "Categories" = list(val = "category")), id.name = "freq_type")
  freq_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "freq_counted_val")
  freq_label <- rk.XML.input(label = "Set Label", initial = "Set", id.name = "freq_label")
  freq_weight <- rk.XML.varslot(label = "Weight", source = "freq_selector", classes = "numeric", id.name = "freq_weight")
  freq_save <- rk.XML.saveobj(label = "Save table", chk = FALSE, initial = "mr_freq_table", id.name = "freq_save_obj")
  freq_preview <- rk.XML.preview(mode = "data")
  dialog_freq <- rk.XML.dialog(label = "Multiple Response Frequencies", child = rk.XML.row(freq_selector, rk.XML.col(rk.XML.tabbook(tabs = list("Data" = rk.XML.col(freq_mode, rk.XML.frame(freq_obj_slot, label="Option A"), rk.XML.frame(freq_vars, freq_type, freq_counted_val, freq_label, label="Option B"), freq_weight), "Options" = rk.XML.col(freq_save, freq_preview))))))
  js_body_freq <- paste0(js_parse_helper, '
    var mode = getValue("freq_mode"); var weight = getValue("freq_weight"); var cmd = ""; var mrset_expr = "";
    if (mode == "pre") { var obj = getValue("freq_obj_slot"); if (obj != "") mrset_expr = obj; } else {
        var vars = getValue("freq_vars"); var type = getValue("freq_type"); var val = getValue("freq_counted_val"); var lbl = getValue("freq_label");
        if (vars != "") {
            var varList = vars.split("\\n"); var colList = []; var dfName = "";
            for (var i = 0; i < varList.length; i++) { var p = parseVar(varList[i]); if (i === 0) dfName = p.df; colList.push(p.raw_col); }
            var cols_str = "c(\\\"" + colList.join("\\\", \\\"") + "\\\")";
            echo("df_temp <- " + dfName + "[, " + cols_str + "]\\n");
            echo(generateLabelingCode(varList));
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { if (val.indexOf("$") > -1 || val.indexOf("[[") > -1) { val_arg = val; } else { val_arg = "\\\"" + val + "\\\""; } }
                echo("for (col in names(df_temp)) { l <- expss::var_lab(df_temp[[col]]); df_temp[[col]] <- ifelse(df_temp[[col]] == " + val_arg + ", l, NA) }\\n");
                mrset_expr = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
            } else { mrset_expr = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")"; }
        }
    }
    if (mrset_expr != "") { if (weight != "") { cmd = "expss::fre(" + mrset_expr + ", weight = " + weight + ")"; } else { cmd = "expss::fre(" + mrset_expr + ")"; } }
  ')
  js_calc_freq <- paste0(js_body_freq, 'if(cmd != "") { echo("mr_freq_table <- " + cmd + "\\n"); } else { echo("stop(\\\"Please select vars.\\\")\\n"); }')
  js_preview_freq <- paste0(js_body_freq, 'if(cmd != "") echo("preview_data <- " + cmd + "\\n");')
  js_print_freq <- 'if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_freq_table)\\n"); }'
  component_freq <- rk.plugin.component("Multiple Response Frequencies", xml = list(dialog = dialog_freq), js = list(require="expss", calculate = js_calc_freq, preview = js_preview_freq, printout = js_print_freq), hierarchy = common_hierarchy, rkh = list(help = help_freq))

  # =========================================================================================
  # COMPONENT 3: Crosstabs (expss)
  # =========================================================================================
  help_cross <- rk.rkh.doc(title = rk.rkh.title("Multiple Response Crosstabs (%)"), summary = rk.rkh.summary("Percentages crosstab."), usage = rk.rkh.usage("Select vars and group."))
  cross_selector <- rk.XML.varselector(id.name = "cross_selector")
  cross_group <- rk.XML.varslot(label = "Column Variable (Group)", source = "cross_selector", required = TRUE, id.name = "cross_group")
  cross_weight <- rk.XML.varslot(label = "Weight", source = "cross_selector", classes = "numeric", id.name = "cross_weight")
  cross_mode <- rk.XML.radio(label = "Row Data Source", options = list("Pre-defined Set" = list(val = "pre", chk = TRUE), "Define On-the-Fly" = list(val = "fly")), id.name = "cross_mode")
  cross_obj_slot <- rk.XML.varslot(label = "Set Object", source = "cross_selector", classes = c("dichotomy", "category", "data.frame"), id.name = "cross_obj_slot")
  cross_vars <- rk.XML.varslot(label = "Row Variables", source = "cross_selector", multi = TRUE, id.name = "cross_vars")
  cross_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies" = list(val = "dichotomy", chk = TRUE), "Categories" = list(val = "category")), id.name = "cross_type")
  cross_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "cross_counted_val")
  cross_label <- rk.XML.input(label = "Set Label", initial = "Responses", id.name = "cross_label")
  cross_save <- rk.XML.saveobj(label = "Save table", chk = FALSE, initial = "mr_crosstab", id.name = "cross_save_obj")
  cross_preview <- rk.XML.preview(mode = "data")
  dialog_cross <- rk.XML.dialog(label = "Multiple Response Crosstabs (%)", child = rk.XML.row(cross_selector, rk.XML.col(rk.XML.tabbook(tabs = list("General" = rk.XML.col(cross_group, cross_weight, cross_mode), "Set Definition" = rk.XML.col(rk.XML.frame(cross_obj_slot, label="Option A"), rk.XML.frame(cross_vars, cross_type, cross_counted_val, cross_label, label="Option B")), "Output" = rk.XML.col(cross_save, cross_preview))))))
  js_body_cross <- paste0(js_parse_helper, '
    var mode = getValue("cross_mode"); var group = getValue("cross_group"); var weight = getValue("cross_weight"); var cmd = ""; var mrset_part = "";
    if (mode == "pre") { var obj = getValue("cross_obj_slot"); if (obj != "") mrset_part = obj; } else {
        var vars = getValue("cross_vars"); var type = getValue("cross_type"); var val = getValue("cross_counted_val"); var lbl = getValue("cross_label");
        if (vars != "") {
            var varList = vars.split("\\n"); var colList = []; var dfName = "";
            for (var i = 0; i < varList.length; i++) { var p = parseVar(varList[i]); if (i === 0) dfName = p.df; colList.push(p.raw_col); }
            var cols_str = "c(\\\"" + colList.join("\\\", \\\"") + "\\\")";
            echo("df_temp <- " + dfName + "[, " + cols_str + "]\\n");
            echo(generateLabelingCode(varList));
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { if (val.indexOf("$") > -1 || val.indexOf("[[") > -1) { val_arg = val; } else { val_arg = "\\\"" + val + "\\\""; } }
                echo("for (col in names(df_temp)) { l <- expss::var_lab(df_temp[[col]]); df_temp[[col]] <- ifelse(df_temp[[col]] == " + val_arg + ", l, NA) }\\n");
                mrset_part = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
            } else { mrset_part = "expss::mrset(df_temp, method = \\\"category\\\", label = \\\"" + lbl + "\\\")"; }
        }
    }
    if (mrset_part != "" && group != "") { if (weight != "") { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ", weight = " + weight + ")"; } else { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ")"; } }
  ')
  js_calc_cross <- paste0(js_body_cross, 'if(cmd != "") { echo("mr_crosstab <- " + cmd + "\\n"); } else { echo("stop(\\\"Select vars.\\\")\\n"); }')
  js_preview_cross <- paste0(js_body_cross, 'if(cmd != "") echo("preview_data <- " + cmd + "\\n");')
  js_print_cross <- 'if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_crosstab)\\n"); }'
  component_cross <- rk.plugin.component("Multiple Response Crosstabs", xml = list(dialog = dialog_cross), js = list(require="expss", calculate = js_calc_cross, preview = js_preview_cross, printout = js_print_cross), hierarchy = common_hierarchy, rkh = list(help = help_cross))

  # =========================================================================================
  # COMPONENT 4: Raw Counts (Pivot) - ENHANCED
  # =========================================================================================

  help_raw <- rk.rkh.doc(
    title = rk.rkh.title(text = "Raw Counts (Pivot)"),
    summary = rk.rkh.summary(text = "Creates detailed tables of raw counts (0/1) for each item, split by a grouping variable. Supports both Dichotomies and Categorical variables."),
    usage = rk.rkh.usage(text = "Select variables and a grouping variable.")
  )

  raw_selector <- rk.XML.varselector(id.name = "raw_selector")
  # UPDATED LABEL
  raw_vars <- rk.XML.varslot(label = "Response Variables", source = "raw_selector", multi = TRUE, required = TRUE, id.name = "raw_vars")
  raw_group <- rk.XML.varslot(label = "Grouping Variable", source = "raw_selector", required = TRUE, id.name = "raw_group")

  # New Options
  raw_use_labels <- rk.XML.cbox(label = "Use RKWard Labels instead of variable names", id.name = "raw_use_labels", value = "1", chk = TRUE)

  raw_opts_frame <- rk.XML.frame(
      rk.XML.cbox(label = "Show Counts", id.name = "raw_show_counts", value = "1", chk = TRUE),
      rk.XML.cbox(label = "Show Row %", id.name = "raw_show_row", value = "1"),
      rk.XML.cbox(label = "Show Column %", id.name = "raw_show_col", value = "1"),
      rk.XML.cbox(label = "Show Table %", id.name = "raw_show_tab", value = "1"),
      rk.XML.cbox(label = "Add Sum Margins", id.name = "raw_margins", value = "1", chk = TRUE),
      label = "Table Statistics"
  )

  raw_preview <- rk.XML.preview(mode = "data")

  dialog_raw <- rk.XML.dialog(
      label = "Raw Counts (Pivot)",
      child = rk.XML.row(
          raw_selector,
          rk.XML.col(
              raw_vars,
              raw_group,
              raw_use_labels,
              raw_opts_frame,
              raw_preview
          )
      )
  )

  js_body_raw <- paste0(js_parse_helper, '
    var vars = getValue("raw_vars");
    var group = getValue("raw_group");
    var use_lbl = getValue("raw_use_labels");

    var varList = vars.split("\\n");
    var colList = [];
    var dfName = "";

    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        colList.push(p.raw_col);
    }

    var groupP = parseVar(group);

    echo("require(tidyr)\\nrequire(dplyr)\\n");

    echo("long_data <- " + dfName + " %>% \\n");
    echo("  dplyr::select(" + groupP.raw_col + ", " + colList.join(", ") + ") %>% \\n");
    echo("  tidyr::pivot_longer(cols = c(" + colList.join(", ") + "), names_to = \\"name\\", values_to = \\"value\\", values_transform = list(value = as.character))\\n");

    // Logic to Apply RKWard Labels to the "name" column
    if (use_lbl == "1") {
        echo("lbl_map <- character(0)\\n");
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             echo("l <- rk.get.label(" + varList[i] + ")\\n");
             echo("if(is.null(l) || l==\\"\\") l <- \\"" + p.raw_col + "\\"\\n");
             echo("lbl_map[\\"" + p.raw_col + "\\"] <- l\\n");
        }
        echo("long_data$name <- factor(long_data$name, levels = names(lbl_map), labels = lbl_map)\\n");
    }

    echo("result_list <- split(long_data, long_data[[" + groupP.col + "]])\\n");
  ')

  js_calc_raw <- paste0(js_body_raw, '
     // No main object needed as we iterate in printout
  ')

  js_preview_raw <- paste0(js_body_raw, '
     echo("preview_data <- long_data\\n");
  ')

  js_print_raw <- '
    if (typeof is_preview === "undefined" || !is_preview) {
        var marg = getValue("raw_margins");
        var s_cnt = getValue("raw_show_counts");
        var s_row = getValue("raw_show_row");
        var s_col = getValue("raw_show_col");
        var s_tab = getValue("raw_show_tab");

        echo("rk.header(\\"Raw Counts (Pivot) by Group\\")\\n");

        echo("for (n in names(result_list)) {\\n");
        echo("  rk.header(paste(\\"Group =\\", n), level=3)\\n");
        echo("  t <- table(result_list[[n]]$name, result_list[[n]]$value)\\n");

        if (s_cnt == "1") {
            echo("  rk.header(\\"Counts\\", level=4)\\n");
            if (marg == "1") echo("  rk.results(addmargins(t))\\n");
            else echo("  rk.results(t)\\n");
        }
        if (s_row == "1") {
             echo("  rk.header(\\"Row %\\", level=4)\\n");
             echo("  rk.results(prop.table(t, 1)*100)\\n");
        }
        if (s_col == "1") {
             echo("  rk.header(\\"Col %\\", level=4)\\n");
             echo("  rk.results(prop.table(t, 2)*100)\\n");
        }
        if (s_tab == "1") {
             echo("  rk.header(\\"Table %\\", level=4)\\n");
             echo("  rk.results(prop.table(t)*100)\\n");
        }
        echo("}\\n");
    }
  '

  component_raw <- rk.plugin.component(
      "Raw Counts (Pivot)",
      xml = list(dialog = dialog_raw),
      js = list(require=c("tidyr", "dplyr"), calculate = js_calc_raw, preview = js_preview_raw, printout = js_print_raw),
      hierarchy = common_hierarchy,
      rkh = list(help = help_raw)
  )

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_freq),
    js = list(require="expss", calculate=js_calc_freq, printout=js_print_freq),
    rkh = list(help=help_freq),
    components = list(component_define, component_cross, component_raw),
    pluginmap = list(name = "Multiple Response Frequencies", hierarchy = common_hierarchy),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE, overwrite = TRUE, show = FALSE
  )

  cat("\nPlugin 'rk.mult.resp' (v0.0.4) updated.\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
