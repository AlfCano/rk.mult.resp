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
  
    var vars = getValue("raw_vars");
    var group = getValue("raw_group");
    var use_lbl = getValue("raw_use_labels");
    
    var varList = vars.split("\n");
    var colList = [];
    var dfName = "";
    
    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        colList.push(p.raw_col);
    }
    
    var groupP = parseVar(group);
    
    echo("require(tidyr)\nrequire(dplyr)\n");
    
    echo("long_data <- " + dfName + " %>% \n");
    echo("  dplyr::select(" + groupP.raw_col + ", " + colList.join(", ") + ") %>% \n");
    echo("  tidyr::pivot_longer(cols = c(" + colList.join(", ") + "), names_to = \"name\", values_to = \"value\", values_transform = list(value = as.character))\n");
    
    // Logic to Apply RKWard Labels to the "name" column
    if (use_lbl == "1") {
        echo("lbl_map <- character(0)\n");
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             echo("l <- rk.get.label(" + varList[i] + ")\n");
             echo("if(is.null(l) || l==\"\") l <- \"" + p.raw_col + "\"\n");
             echo("lbl_map[\"" + p.raw_col + "\"] <- l\n");
        }
        echo("long_data$name <- factor(long_data$name, levels = names(lbl_map), labels = lbl_map)\n");
    }

    echo("result_list <- split(long_data, long_data[[" + groupP.col + "]])\n");
  
     echo("preview_data <- long_data\n");
  
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(tidyr)){stop(" + i18n("Preview not available, because package tidyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(tidyr)\n");
	}	if(is_preview) {
		echo("if(!base::require(dplyr)){stop(" + i18n("Preview not available, because package dplyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(dplyr)\n");
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
  
    var vars = getValue("raw_vars");
    var group = getValue("raw_group");
    var use_lbl = getValue("raw_use_labels");
    
    var varList = vars.split("\n");
    var colList = [];
    var dfName = "";
    
    for (var i = 0; i < varList.length; i++) {
        var p = parseVar(varList[i]);
        if (i === 0) dfName = p.df;
        colList.push(p.raw_col);
    }
    
    var groupP = parseVar(group);
    
    echo("require(tidyr)\nrequire(dplyr)\n");
    
    echo("long_data <- " + dfName + " %>% \n");
    echo("  dplyr::select(" + groupP.raw_col + ", " + colList.join(", ") + ") %>% \n");
    echo("  tidyr::pivot_longer(cols = c(" + colList.join(", ") + "), names_to = \"name\", values_to = \"value\", values_transform = list(value = as.character))\n");
    
    // Logic to Apply RKWard Labels to the "name" column
    if (use_lbl == "1") {
        echo("lbl_map <- character(0)\n");
        for (var i = 0; i < varList.length; i++) {
             var p = parseVar(varList[i]);
             echo("l <- rk.get.label(" + varList[i] + ")\n");
             echo("if(is.null(l) || l==\"\") l <- \"" + p.raw_col + "\"\n");
             echo("lbl_map[\"" + p.raw_col + "\"] <- l\n");
        }
        echo("long_data$name <- factor(long_data$name, levels = names(lbl_map), labels = lbl_map)\n");
    }

    echo("result_list <- split(long_data, long_data[[" + groupP.col + "]])\n");
  
     // No main object needed as we iterate in printout
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Raw Counts (Pivot) results")).print();	
	}
    if (typeof is_preview === "undefined" || !is_preview) {
        var marg = getValue("raw_margins");
        var s_cnt = getValue("raw_show_counts");
        var s_row = getValue("raw_show_row");
        var s_col = getValue("raw_show_col");
        var s_tab = getValue("raw_show_tab");

        echo("rk.header(\"Raw Counts (Pivot) by Group\")\n");
        
        echo("for (n in names(result_list)) {\n");
        echo("  rk.header(paste(\"Group =\", n), level=3)\n");
        echo("  t <- table(result_list[[n]]$name, result_list[[n]]$value)\n");
        
        if (s_cnt == "1") {
            echo("  rk.header(\"Counts\", level=4)\n");
            if (marg == "1") echo("  rk.results(addmargins(t))\n");
            else echo("  rk.results(t)\n");
        }
        if (s_row == "1") {
             echo("  rk.header(\"Row %\", level=4)\n");
             echo("  rk.results(prop.table(t, 1)*100)\n");
        }
        if (s_col == "1") {
             echo("  rk.header(\"Col %\", level=4)\n");
             echo("  rk.results(prop.table(t, 2)*100)\n");
        }
        if (s_tab == "1") {
             echo("  rk.header(\"Table %\", level=4)\n");
             echo("  rk.results(prop.table(t)*100)\n");
        }
        echo("}\n");
    }
  

}

