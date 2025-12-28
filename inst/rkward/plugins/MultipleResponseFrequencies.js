// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
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
  
    var mode = getValue("freq_mode"); var weight = getValue("freq_weight"); var cmd = ""; var mrset_expr = "";
    if (mode == "pre") { var obj = getValue("freq_obj_slot"); if (obj != "") mrset_expr = obj; } else {
        var vars = getValue("freq_vars"); var type = getValue("freq_type"); var val = getValue("freq_counted_val"); var lbl = getValue("freq_label");
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
                mrset_expr = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")";
            } else { mrset_expr = "expss::mrset(df_temp, method = \"category\", label = \"" + lbl + "\")"; }
        }
    }
    if (mrset_expr != "") { if (weight != "") { cmd = "expss::fre(" + mrset_expr + ", weight = " + weight + ")"; } else { cmd = "expss::fre(" + mrset_expr + ")"; } }
  if(cmd != "") { echo("mr_freq_table <- " + cmd + "\n"); } else { echo("stop(\"Please select vars.\")\n"); }
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Multiple Response Frequencies results")).print();	
	}if (typeof is_preview === "undefined" || !is_preview) { echo("rk.results(mr_freq_table)\n"); }
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var freqSaveObj = getValue("freq_save_obj");
		var freqSaveObjActive = getValue("freq_save_obj.active");
		var freqSaveObjParent = getValue("freq_save_obj.parent");
		// assign object to chosen environment
		if(freqSaveObjActive) {
			echo(".GlobalEnv$" + freqSaveObj + " <- mr_freq_table\n");
		}	
	}

}

