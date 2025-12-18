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
        return { 
            df: df, 
            col: '\"' + raw_col + '\"', 
            raw_col: raw_col 
        };
    }
  
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
            var varList = vars.split("\n");
            var colList = [];
            var dfName = "";
            for (var i = 0; i < varList.length; i++) {
                var p = parseVar(varList[i]);
                if (i === 0) dfName = p.df;
                colList.push(p.raw_col);
            }
            var cols_str = "c(\"" + colList.join("\", \"") + "\")";
            var data_ref = dfName + "[, " + cols_str + "]";
            
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { val_arg = "\"" + val + "\""; }
                mrset_part = "expss::mrset(" + data_ref + ", method = \"dichotomy\", label = \"" + lbl + "\", number_of_items = " + val_arg + ")";
            } else {
                mrset_part = "expss::mrset(" + data_ref + ", method = \"category\", label = \"" + lbl + "\")";
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
        return { 
            df: df, 
            col: '\"' + raw_col + '\"', 
            raw_col: raw_col 
        };
    }
  
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
            var varList = vars.split("\n");
            var colList = [];
            var dfName = "";
            for (var i = 0; i < varList.length; i++) {
                var p = parseVar(varList[i]);
                if (i === 0) dfName = p.df;
                colList.push(p.raw_col);
            }
            var cols_str = "c(\"" + colList.join("\", \"") + "\")";
            var data_ref = dfName + "[, " + cols_str + "]";
            
            if (type == "dichotomy") {
                var val_arg = val;
                if (isNaN(val)) { val_arg = "\"" + val + "\""; }
                mrset_part = "expss::mrset(" + data_ref + ", method = \"dichotomy\", label = \"" + lbl + "\", number_of_items = " + val_arg + ")";
            } else {
                mrset_part = "expss::mrset(" + data_ref + ", method = \"category\", label = \"" + lbl + "\")";
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
  if(cmd != "") { echo("mr_crosstab <- " + cmd + "\n"); } else { echo("stop(\"Please select valid Set and Group variables.\")\n"); }
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

