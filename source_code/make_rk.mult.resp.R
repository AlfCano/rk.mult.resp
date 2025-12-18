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
      desc = "An RKWard plugin package for analyzing multiple response sets (dichotomies or categories) using the 'expss' library.",
      version = "0.0.1", # FROZEN
      url = "https://github.com/AlfCano/rk.mult.resp",
      license = "GPL (>= 3)"
    )
  )

  # Menu Hierarchy: Analysis -> Multiple Response
  common_hierarchy <- list("analysis", "Multiple Response (expss)")

  # =========================================================================================
  # 2. JS Helper (Variable Parsing)
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
        return {
            df: df,
            col: '\\\"' + raw_col + '\\\"',
            raw_col: raw_col
        };
    }
  "

  # =========================================================================================
  # COMPONENT 1: Frequencies (MAIN PLUGIN)
  # =========================================================================================

  help_freq <- rk.rkh.doc(
    title = rk.rkh.title(text = "Multiple Response Frequencies"),
    summary = rk.rkh.summary(text = "Calculate counts and percentages for multiple response sets (Check-all-that-apply questions)."),
    usage = rk.rkh.usage(text = "Select the variables that make up the set. Choose the coding method (Dichotomy or Category).")
  )

  freq_selector <- rk.XML.varselector(id.name = "freq_selector")

  # Tab 1: Data
  freq_vars <- rk.XML.varslot(label = "Variables in Set", source = "freq_selector", multi = TRUE, required = TRUE, id.name = "freq_vars")
  freq_type <- rk.XML.radio(label = "Set Type", options = list(
      "Dichotomies (Counted value)" = list(val = "dichotomy", chk = TRUE),
      "Categories (Multiple columns)" = list(val = "category")
  ), id.name = "freq_type")
  freq_counted_val <- rk.XML.input(label = "Counted Value (e.g., 1 or 'Yes')", initial = "1", id.name = "freq_counted_val")
  freq_label <- rk.XML.input(label = "Set Label (Optional)", initial = "Multiple Response Set", id.name = "freq_label")

  # Tab 2: Options
  freq_save <- rk.XML.saveobj(label = "Save table as", chk = FALSE, initial = "mr_freq_table", id.name = "freq_save_obj")

  # CHANGED: Mode set to "data" for reliable dataframe preview
  freq_preview <- rk.XML.preview(mode = "data")

  dialog_freq <- rk.XML.dialog(
    label = "Multiple Response Frequencies",
    child = rk.XML.row(
        freq_selector,
        rk.XML.col(
            rk.XML.tabbook(tabs = list(
                "Data" = rk.XML.col(
                    freq_vars,
                    rk.XML.frame(freq_type, freq_counted_val, freq_label, label = "Definition")
                ),
                "Options" = rk.XML.col(
                    freq_save,
                    freq_preview
                )
            ))
        )
    )
  )

  js_body_freq <- paste0(js_parse_helper, '
    var vars = getValue("freq_vars");
    var type = getValue("freq_type");
    var val = getValue("freq_counted_val");
    var lbl = getValue("freq_label");

    var varList = vars.split("\\n");
    var colList = [];
    var dfName = "";

    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        colList.push(p.raw_col);
    }

    var cols_str = "c(\\\"" + colList.join("\\\", \\\"") + "\\\")";
    var data_ref = dfName + "[, " + cols_str + "]";

    var mrset_cmd = "";

    if (type == "dichotomy") {
        var val_arg = val;
        if (isNaN(val)) { val_arg = "\\\"" + val + "\\\""; }

        mrset_cmd = "expss::mrset(" + data_ref + ", method = \\\"dichotomy\\\", label = \\\"" + lbl + "\\\", number_of_items = " + val_arg + ")";
    } else {
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
    }

    var cmd = "expss::fre(" + mrset_cmd + ")";
  ')

  js_calc_freq <- paste0(js_body_freq, '
    echo("mr_freq_table <- " + cmd + "\\n");
  ')

  # Preview: Assign to preview_data (Data Mode)
  js_preview_freq <- paste0(js_body_freq, '
    echo("preview_data <- " + cmd + "\\n");
  ')

  # Printout: Output window HTML using rk.results
  js_print_freq <- '
    echo("rk.results(mr_freq_table)\\n");
  '

  # Defined but NOT added to component list (Main Plugin)
  component_freq <- rk.plugin.component(
    "Multiple Response Frequencies",
    xml = list(dialog = dialog_freq),
    js = list(require="expss", calculate = js_calc_freq, preview = js_preview_freq, printout = js_print_freq),
    hierarchy = common_hierarchy,
    rkh = list(help = help_freq)
  )

  # =========================================================================================
  # COMPONENT 2: Crosstabs
  # =========================================================================================

  help_cross <- rk.rkh.doc(
    title = rk.rkh.title(text = "Multiple Response Crosstabs"),
    summary = rk.rkh.summary(text = "Create crosstabs of a multiple response set against a categorical group."),
    usage = rk.rkh.usage(text = "Select the variables for the Set (Rows) and a Grouping variable (Column).")
  )

  cross_selector <- rk.XML.varselector(id.name = "cross_selector")

  # Tab 1: Data
  cross_vars <- rk.XML.varslot(label = "Row Variables (The Set)", source = "cross_selector", multi = TRUE, required = TRUE, id.name = "cross_vars")
  cross_group <- rk.XML.varslot(label = "Column Variable (Group)", source = "cross_selector", required = TRUE, id.name = "cross_group")
  cross_type <- rk.XML.radio(label = "Set Type", options = list(
      "Dichotomies (Counted value)" = list(val = "dichotomy", chk = TRUE),
      "Categories (Multiple columns)" = list(val = "category")
  ), id.name = "cross_type")
  cross_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "cross_counted_val")
  cross_label <- rk.XML.input(label = "Set Label", initial = "Responses", id.name = "cross_label")

  # Tab 2: Options
  cross_save <- rk.XML.saveobj(label = "Save table as", chk = FALSE, initial = "mr_crosstab", id.name = "cross_save_obj")

  # CHANGED: Mode set to "data" for reliable dataframe preview
  cross_preview <- rk.XML.preview(mode = "data")

  dialog_cross <- rk.XML.dialog(
    label = "Multiple Response Crosstabs",
    child = rk.XML.row(
        cross_selector,
        rk.XML.col(
            rk.XML.tabbook(tabs = list(
                "Data" = rk.XML.col(
                    cross_vars,
                    cross_group,
                    rk.XML.frame(cross_type, cross_counted_val, cross_label, label = "Set Definition")
                ),
                "Options" = rk.XML.col(
                    cross_save,
                    cross_preview
                )
            ))
        )
    )
  )

  js_body_cross <- paste0(js_parse_helper, '
    var vars = getValue("cross_vars");
    var group = getValue("cross_group");
    var type = getValue("cross_type");
    var val = getValue("cross_counted_val");
    var lbl = getValue("cross_label");

    var varList = vars.split("\\n");
    var colList = [];
    var dfName = "";

    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        colList.push(p.raw_col);
    }

    var group_p = parseVar(group);

    var cols_str = "c(\\\"" + colList.join("\\\", \\\"") + "\\\")";
    var data_ref = dfName + "[, " + cols_str + "]";

    var mrset_cmd = "";
    if (type == "dichotomy") {
        var val_arg = val;
        if (isNaN(val)) { val_arg = "\\\"" + val + "\\\""; }
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \\\"dichotomy\\\", label = \\\"" + lbl + "\\\", number_of_items = " + val_arg + ")";
    } else {
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
    }

    var cmd = "expss::cro_cpct(" + mrset_cmd + ", " + group + ")";
  ')

  js_calc_cross <- paste0(js_body_cross, '
    echo("mr_crosstab <- " + cmd + "\\n");
  ')

  # Preview: Assign to preview_data (Data Mode)
  js_preview_cross <- paste0(js_body_cross, '
    echo("preview_data <- " + cmd + "\\n");
  ')

  # Printout: Output window HTML using rk.results
  js_print_cross <- '
    echo("rk.results(mr_crosstab)\\n");
  '

  component_cross <- rk.plugin.component(
    "Multiple Response Crosstabs",
    xml = list(dialog = dialog_cross),
    js = list(require="expss", calculate = js_calc_cross, preview = js_preview_cross, printout = js_print_cross),
    hierarchy = common_hierarchy,
    rkh = list(help = help_cross)
  )

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    # Main Plugin (Frequencies)
    xml = list(dialog = dialog_freq),
    js = list(
        require = "expss",
        calculate = js_calc_freq,
        printout = js_print_freq,
        preview = js_preview_freq
    ),
    rkh = list(help = help_freq),
    # Sub-components (Crosstabs)
    components = list(
        component_cross
    ),
    pluginmap = list(
        name = "Multiple Response Frequencies",
        hierarchy = common_hierarchy
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.mult.resp' (v0.0.1) generated successfully.\n")
  cat("To complete installation:\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
