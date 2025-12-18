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
      version = "0.0.3",
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
        return {
            df: df,
            col: '\\\"' + raw_col + '\\\"',
            raw_col: raw_col
        };
    }
  "

  # =========================================================================================
  # COMPONENT 1: Define Variable Set
  # =========================================================================================

  help_define <- rk.rkh.doc(
    title = rk.rkh.title(text = "Define Multiple Response Set"),
    summary = rk.rkh.summary(text = "Define a set of variables as a Multiple Response Set (Dichotomy or Category) and save it as an object."),
    usage = rk.rkh.usage(text = "Select variables, define the coding scheme, and optionally check the results with a weight variable.")
  )

  def_selector <- rk.XML.varselector(id.name = "def_selector")
  def_vars <- rk.XML.varslot(label = "Variables in Set", source = "def_selector", multi = TRUE, required = TRUE, id.name = "def_vars")
  def_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies (Counted value)" = list(val = "dichotomy", chk = TRUE), "Categories (Multiple columns)" = list(val = "category")), id.name = "def_type")
  def_counted_val <- rk.XML.input(label = "Counted Value (e.g., 1)", initial = "1", id.name = "def_counted_val")
  def_label <- rk.XML.input(label = "Set Label", initial = "My Response Set", id.name = "def_label")
  def_weight <- rk.XML.varslot(label = "Weight Variable (For Preview/Verification)", source = "def_selector", classes = "numeric", id.name = "def_weight")
  def_save <- rk.XML.saveobj(label = "Save Set as", chk = TRUE, initial = "my_mrset", id.name = "def_save_obj")
  def_preview <- rk.XML.preview(mode = "data")

  dialog_define <- rk.XML.dialog(
    label = "Define Multiple Response Set",
    child = rk.XML.row(def_selector, rk.XML.col(def_vars, rk.XML.frame(def_type, def_counted_val, def_label, label = "Definition"), def_weight, def_save, def_preview))
  )

  js_body_define <- paste0(js_parse_helper, '
    var vars = getValue("def_vars");
    var type = getValue("def_type");
    var val = getValue("def_counted_val");
    var lbl = getValue("def_label");
    var weight = getValue("def_weight");

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
  ')

  js_calc_define <- paste0(js_body_define, 'echo("my_mrset <- " + mrset_cmd + "\\n");')
  js_preview_define <- paste0(js_body_define, '
    echo("temp_mrset <- " + mrset_cmd + "\\n");
    if (weight != "") {
        echo("preview_data <- expss::fre(temp_mrset, weight = " + weight + ")\\n");
    } else {
        echo("preview_data <- expss::fre(temp_mrset)\\n");
    }
  ')
  js_print_define <- 'var save_name = getValue("def_save_obj.objectname"); echo("rk.header(\\"Multiple Response Set Defined: " + save_name + "\\", level=3);\\n");'

  component_define <- rk.plugin.component("Define Variable Set", xml = list(dialog = dialog_define), js = list(require="expss", calculate = js_calc_define, preview = js_preview_define, printout = js_print_define), hierarchy = common_hierarchy, rkh = list(help = help_define))

  # =========================================================================================
  # COMPONENT 2: Frequencies (MAIN)
  # =========================================================================================

  help_freq <- rk.rkh.doc(title = rk.rkh.title(text = "Multiple Response Frequencies"), summary = rk.rkh.summary(text = "Calculate counts and percentages for multiple response sets."), usage = rk.rkh.usage(text = "Select a pre-defined set or define one on the fly."))

  freq_selector <- rk.XML.varselector(id.name = "freq_selector")
  freq_mode <- rk.XML.radio(label = "Data Source", options = list("Pre-defined Set (Object)" = list(val = "pre", chk = TRUE), "Define On-the-Fly (Raw Vars)" = list(val = "fly")), id.name = "freq_mode")
  freq_obj_slot <- rk.XML.varslot(label = "Select Set Object", source = "freq_selector", classes = c("dichotomy", "category", "data.frame"), id.name = "freq_obj_slot")
  freq_vars <- rk.XML.varslot(label = "Variables in Set", source = "freq_selector", multi = TRUE, id.name = "freq_vars")
  freq_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies" = list(val = "dichotomy", chk = TRUE), "Categories" = list(val = "category")), id.name = "freq_type")
  freq_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "freq_counted_val")
  freq_label <- rk.XML.input(label = "Set Label", initial = "Set", id.name = "freq_label")
  freq_weight <- rk.XML.varslot(label = "Weight Variable (Optional)", source = "freq_selector", classes = "numeric", id.name = "freq_weight")
  freq_save <- rk.XML.saveobj(label = "Save table as", chk = FALSE, initial = "mr_freq_table", id.name = "freq_save_obj")
  freq_preview <- rk.XML.preview(mode = "data")

  dialog_freq <- rk.XML.dialog(label = "Multiple Response Frequencies", child = rk.XML.row(freq_selector, rk.XML.col(rk.XML.tabbook(tabs = list("Data" = rk.XML.col(freq_mode, rk.XML.frame(freq_obj_slot, label = "Option A: Use Existing Set"), rk.XML.frame(freq_vars, freq_type, freq_counted_val, freq_label, label = "Option B: Define On-the-Fly"), freq_weight), "Options" = rk.XML.col(freq_save, freq_preview))))))

  js_body_freq <- paste0(js_parse_helper, '
    var mode = getValue("freq_mode");
    var weight = getValue("freq_weight");
    var cmd = "";
    var mrset_expr = "";

    if (mode == "pre") {
        var obj = getValue("freq_obj_slot");
        if (obj != "") mrset_expr = obj;
    } else {
        var vars = getValue("freq_vars");
        var type = getValue("freq_type");
        var val = getValue("freq_counted_val");
        var lbl = getValue("freq_label");

        if (vars != "") {
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

            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { val_arg = "\\\"" + val + "\\\""; }
                mrset_expr = "expss::mrset(" + data_ref + ", method = \\\"dichotomy\\\", label = \\\"" + lbl + "\\\", number_of_items = " + val_arg + ")";
            } else {
                mrset_expr = "expss::mrset(" + data_ref + ", method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
            }
        }
    }

    if (mrset_expr != "") {
        if (weight != "") {
            cmd = "expss::fre(" + mrset_expr + ", weight = " + weight + ")";
        } else {
            cmd = "expss::fre(" + mrset_expr + ")";
        }
    }
  ')

  js_calc_freq <- paste0(js_body_freq, 'if(cmd != "") { echo("mr_freq_table <- " + cmd + "\\n"); } else { echo("stop(\\\"Please select a set object or variables.\\\")\\n"); }')
  js_preview_freq <- paste0(js_body_freq, 'if(cmd != "") echo("preview_data <- " + cmd + "\\n");')
  js_print_freq <- 'if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_freq_table)\\n"); }'

  component_freq <- rk.plugin.component("Multiple Response Frequencies", xml = list(dialog = dialog_freq), js = list(require="expss", calculate = js_calc_freq, preview = js_preview_freq, printout = js_print_freq), hierarchy = common_hierarchy, rkh = list(help = help_freq))

  # =========================================================================================
  # COMPONENT 3: Crosstabs (CORRECTED)
  # =========================================================================================

  help_cross <- rk.rkh.doc(title = rk.rkh.title(text = "Multiple Response Crosstabs"), summary = rk.rkh.summary(text = "Create crosstabs of a multiple response set against a categorical group."), usage = rk.rkh.usage(text = "Select variables and group."))

  cross_selector <- rk.XML.varselector(id.name = "cross_selector")
  cross_mode <- rk.XML.radio(label = "Row Data Source", options = list("Pre-defined Set (Object)" = list(val = "pre", chk = TRUE), "Define On-the-Fly (Raw Vars)" = list(val = "fly")), id.name = "cross_mode")
  cross_group <- rk.XML.varslot(label = "Column Variable (Group)", source = "cross_selector", required = TRUE, id.name = "cross_group")
  cross_weight <- rk.XML.varslot(label = "Weight Variable (Optional)", source = "cross_selector", classes = "numeric", id.name = "cross_weight")
  cross_obj_slot <- rk.XML.varslot(label = "Select Set Object", source = "cross_selector", classes = c("dichotomy", "category", "data.frame"), id.name = "cross_obj_slot")
  cross_vars <- rk.XML.varslot(label = "Row Variables (The Set)", source = "cross_selector", multi = TRUE, id.name = "cross_vars")
  cross_type <- rk.XML.radio(label = "Set Type", options = list("Dichotomies" = list(val = "dichotomy", chk = TRUE), "Categories" = list(val = "category")), id.name = "cross_type")
  cross_counted_val <- rk.XML.input(label = "Counted Value", initial = "1", id.name = "cross_counted_val")
  cross_label <- rk.XML.input(label = "Set Label", initial = "Responses", id.name = "cross_label")
  cross_save <- rk.XML.saveobj(label = "Save table as", chk = FALSE, initial = "mr_crosstab", id.name = "cross_save_obj")
  cross_preview <- rk.XML.preview(mode = "data")

  dialog_cross <- rk.XML.dialog(label = "Multiple Response Crosstabs", child = rk.XML.row(cross_selector, rk.XML.col(rk.XML.tabbook(tabs = list("Data" = rk.XML.col(cross_group, cross_mode, rk.XML.frame(cross_obj_slot, label = "Option A: Use Existing Set"), rk.XML.frame(cross_vars, cross_type, cross_counted_val, cross_label, label = "Option B: Define On-the-Fly"), cross_weight), "Options" = rk.XML.col(cross_save, cross_preview))))))

  # CLEANED & CORRECTED LOGIC
  js_body_cross <- paste0(js_parse_helper, '
    var mode = getValue("cross_mode");
    var group = getValue("cross_group");
    var weight = getValue("cross_weight");
    var cmd = "";
    var mrset_part = "";

    if (mode == "pre") {
        var obj = getValue("cross_obj_slot");
        if (obj != "") mrset_part = obj;
    } else {
        var vars = getValue("cross_vars");
        var type = getValue("cross_type");
        var val = getValue("cross_counted_val");
        var lbl = getValue("cross_label");

        if (vars != "") {
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

            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { val_arg = "\\\"" + val + "\\\""; }
                mrset_part = "expss::mrset(" + data_ref + ", method = \\\"dichotomy\\\", label = \\\"" + lbl + "\\\", number_of_items = " + val_arg + ")";
            } else {
                mrset_part = "expss::mrset(" + data_ref + ", method = \\\"category\\\", label = \\\"" + lbl + "\\\")";
            }
        }
    }

    if (mrset_part != "" && group != "") {
        if (weight != "") {
            cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ", weight = " + weight + ")";
        } else {
            cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ")";
        }
    }
  ')

  js_calc_cross <- paste0(js_body_cross, 'if(cmd != "") { echo("mr_crosstab <- " + cmd + "\\n"); } else { echo("stop(\\\"Please select valid Set and Group variables.\\\")\\n"); }')
  js_preview_cross <- paste0(js_body_cross, 'if(cmd != "") echo("preview_data <- " + cmd + "\\n");')
  js_print_cross <- 'if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_crosstab)\\n"); }'

  component_cross <- rk.plugin.component("Multiple Response Crosstabs", xml = list(dialog = dialog_cross), js = list(require="expss", calculate = js_calc_cross, preview = js_preview_cross, printout = js_print_cross), hierarchy = common_hierarchy, rkh = list(help = help_cross))

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_freq),
    js = list(
        require = "expss",
        calculate = js_calc_freq,
        printout = js_print_freq,
        preview = js_preview_freq
    ),
    rkh = list(help = help_freq),
    components = list(
        component_define,
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

  cat("\nPlugin package 'rk.mult.resp' (v0.0.3) corrected (JavaScript logic restored).\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
