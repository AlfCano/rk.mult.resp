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
  
    var vars = getValue("freq_vars");
    var type = getValue("freq_type");
    var val = getValue("freq_counted_val");
    var lbl = getValue("freq_label");
    
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
    
    var mrset_cmd = "";
    
    if (type == "dichotomy") {
        var val_arg = val;
        if (isNaN(val)) { val_arg = "\"" + val + "\""; }
        
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \"dichotomy\", label = \"" + lbl + "\", number_of_items = " + val_arg + ")";
    } else {
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \"category\", label = \"" + lbl + "\")";
    }
    
    var cmd = "expss::fre(" + mrset_cmd + ")";
  
    echo("preview_data <- " + cmd + "\n");
  
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
  
    var vars = getValue("freq_vars");
    var type = getValue("freq_type");
    var val = getValue("freq_counted_val");
    var lbl = getValue("freq_label");
    
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
    
    var mrset_cmd = "";
    
    if (type == "dichotomy") {
        var val_arg = val;
        if (isNaN(val)) { val_arg = "\"" + val + "\""; }
        
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \"dichotomy\", label = \"" + lbl + "\", number_of_items = " + val_arg + ")";
    } else {
        mrset_cmd = "expss::mrset(" + data_ref + ", method = \"category\", label = \"" + lbl + "\")";
    }
    
    var cmd = "expss::fre(" + mrset_cmd + ")";
  
    echo("mr_freq_table <- " + cmd + "\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Multiple Response Frequencies results")).print();	
	}
    echo("rk.results(mr_freq_table)\n");
  
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

