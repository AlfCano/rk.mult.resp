// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        var df = '';
        var raw_col = '';
        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/["']/g, '');
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return { df: df, col: '\"' + raw_col + '\"', raw_col: raw_col };
    }

    function generateLabelingCode(varList) {
        var code = '';
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             code += 'lbl <- rk.get.label(' + varList[i] + ')\n';
             code += 'if(is.null(lbl) || lbl == "") lbl <- "' + p.raw_col + '"\n';
             code += 'expss::var_lab(df_temp[[' + p.col + ']]) <- lbl\n';
        }
        return code;
    }
  
    var mode = getValue("cross_mode"); var group = getValue("cross_group"); var weight = getValue("cross_weight"); var cmd = ""; var mrset_part = "";
    if (mode == "pre") { var obj = getValue("cross_obj_slot"); if (obj != "") mrset_part = obj; } else {
        var vars = getValue("cross_vars"); var type = getValue("cross_type"); var val = getValue("cross_counted_val"); var lbl = getValue("cross_label");
        if (vars != "") {
            var varList = vars.split("\n"); var colList = []; var dfName = "";
            for (var i = 0; i < varList.length; i++) { var p = parseVar(varList[i]); if (i === 0) dfName = p.df; colList.push(p.raw_col); }
            var cols_str = "c(\"" + colList.join("\", \"") + "\")";
            echo("df_temp <- " + dfName + "[, " + cols_str + "]\n");
            echo(generateLabelingCode(varList));
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { if (val.indexOf("$") > -1 || val.indexOf("[[") > -1) { val_arg = val; } else { val_arg = "\"" + val + "\""; } }
                echo("for (col in names(df_temp)) { l <- expss::var_lab(df_temp[[col]]); df_temp[[col]] <- ifelse(df_temp[[col]] == " + val_arg + ", l, NA) }\n");
                mrset_part = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")";
            } else { mrset_part = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")"; }
        }
    }
    if (mrset_part != "" && group != "") { if (weight != "") { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ", weight = " + weight + ")"; } else { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ")"; } }
  if(cmd != "") echo("preview_data <- " + cmd + "\n");
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(expss)){stop(" + i18n("Preview not available, because package expss is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(expss)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        var df = '';
        var raw_col = '';
        if (fullPath.indexOf('[[') > -1) {
            var parts = fullPath.split('[[');
            df = parts[0];
            var inner = parts[1].replace(']]', '');
            raw_col = inner.replace(/["']/g, '');
        } else if (fullPath.indexOf('$') > -1) {
            var parts = fullPath.split('$');
            df = parts[0];
            raw_col = parts[1];
        } else {
            raw_col = fullPath;
        }
        return { df: df, col: '\"' + raw_col + '\"', raw_col: raw_col };
    }

    function generateLabelingCode(varList) {
        var code = '';
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             code += 'lbl <- rk.get.label(' + varList[i] + ')\n';
             code += 'if(is.null(lbl) || lbl == "") lbl <- "' + p.raw_col + '"\n';
             code += 'expss::var_lab(df_temp[[' + p.col + ']]) <- lbl\n';
        }
        return code;
    }
  
    var mode = getValue("cross_mode"); var group = getValue("cross_group"); var weight = getValue("cross_weight"); var cmd = ""; var mrset_part = "";
    if (mode == "pre") { var obj = getValue("cross_obj_slot"); if (obj != "") mrset_part = obj; } else {
        var vars = getValue("cross_vars"); var type = getValue("cross_type"); var val = getValue("cross_counted_val"); var lbl = getValue("cross_label");
        if (vars != "") {
            var varList = vars.split("\n"); var colList = []; var dfName = "";
            for (var i = 0; i < varList.length; i++) { var p = parseVar(varList[i]); if (i === 0) dfName = p.df; colList.push(p.raw_col); }
            var cols_str = "c(\"" + colList.join("\", \"") + "\")";
            echo("df_temp <- " + dfName + "[, " + cols_str + "]\n");
            echo(generateLabelingCode(varList));
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { if (val.indexOf("$") > -1 || val.indexOf("[[") > -1) { val_arg = val; } else { val_arg = "\"" + val + "\""; } }
                echo("for (col in names(df_temp)) { l <- expss::var_lab(df_temp[[col]]); df_temp[[col]] <- ifelse(df_temp[[col]] == " + val_arg + ", l, NA) }\n");
                mrset_part = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")";
            } else { mrset_part = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")"; }
        }
    }
    if (mrset_part != "" && group != "") { if (weight != "") { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ", weight = " + weight + ")"; } else { cmd = "expss::cro_cpct(" + mrset_part + ", " + group + ")"; } }
  if(cmd != "") { echo("mr_crosstab <- " + cmd + "\n"); } else { echo("stop(\"Select vars.\")\n"); }
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Multiple Response Crosstabs results")).print();	
	}if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_crosstab)\n"); }
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var crossSaveObj = getValue("cross_save_obj");
		var crossSaveObjActive = getValue("cross_save_obj.active");
		var crossSaveObjParent = getValue("cross_save_obj.parent");
		// assign object to chosen environment
		if(crossSaveObjActive) {
			echo(".GlobalEnv$" + crossSaveObj + " <- mr_crosstab\n");
		}	
	}

}

