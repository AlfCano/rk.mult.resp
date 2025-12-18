# rk.mult.resp: Multiple Response Analysis for RKWard

![Version](https://img.shields.io/badge/Version-0.0.2-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

This package provides a suite of RKWard plugins for analyzing **Multiple Response Sets** (also known as "Check-all-that-apply" questions). Powered by the **`expss`** package, it brings SPSS-style tables and logic to RKWard, allowing you to define, tabulate, and cross-tabulate complex survey data (including survey weights) without writing code.

## Features / Included Plugins

This package installs a new submenu in RKWard: **Analysis > Multiple Response (expss)**.

*   **Define Variable Set:**
    *   Define a reusable Multiple Response Set object (Dichotomies or Categories) and save it to your workspace.
    *   **Verification:** Includes a specific slot for a **Weight Variable** to preview weighted results immediately, ensuring your definition matches expected report totals.

*   **Multiple Response Frequencies:**
    *   Calculate counts and percentages for response sets.
    *   **Flexible Input:** Use a Pre-defined Set object OR define variables on-the-fly.
    *   **Weighting:** Apply a weight variable to calculate representative population estimates.

*   **Multiple Response Crosstabs:**
    *   Cross-tabulate a Multiple Response Set (Rows) against a categorical Grouping variable (Columns).
    *   **Statistics:** Automatically calculates Column Percentages (Standard "Banner" table format).
    *   **Weighting:** Full support for weighted cross-tabulation.

## Requirements

1.  A working installation of **RKWard**.
2.  The R package **`expss`**.
    ```R
    install.packages("expss")
    ```
3.  The R package **`devtools`** (for installation from source).

## Installation

1.  Open R in RKWard.
2.  Run the following commands in the R console:

```R
local({
## Preparar
require(devtools)
## Computar
  install_github(
    repo="AlfCano/rk.mult.resp"
  )
## Imprimir el resultado
rk.header ("Resultados de Instalar desde git")
})
```
3.  Restart RKWard to ensure the new menu items appear correctly.

## Usage & Examples

### Step 0: Create Sample Data
To properly test the weighting features, use this dataset which includes randomized weights:

```R
set.seed(123) # Reproducible random weights
survey_data <- data.frame(
  id = 1:10,
  gender = c("Male", "Female", "Female", "Male", "Male", "Female", "Male", "Female", "Male", "Female"),
  
  # Random weights (0.5 to 2.0) so weighted results differ from unweighted
  wt = runif(10, min=0.5, max=2.0),
  
  # Dichotomies (1=Yes, 0=No)
  device_phone  = c(1, 1, 1, 1, 1, 1, 0, 1, 1, 1),
  device_tablet = c(0, 1, 1, 0, 0, 1, 0, 1, 0, 1),
  device_laptop = c(1, 1, 0, 1, 1, 0, 1, 1, 1, 0)
)
```

### Example 1: Define a Set (with Verification)
1.  Navigate to **Analysis > Multiple Response (expss) > Define Variable Set**.
2.  **Variables in Set:** Select `device_phone`, `device_tablet`, and `device_laptop`.
3.  **Set Type:** "Dichotomies", Counted Value: `1`.
4.  **Weight Variable (Optional):** Select `wt`.
5.  **Save Set as:** `device_set`.
6.  Click **Submit** (or Preview).
    *   *Result:* An object `device_set` is saved to your workspace. The output window shows a weighted frequency table confirming the definition.

### Example 2: Weighted Frequencies
1.  Navigate to **Analysis > Multiple Response (expss) > Multiple Response Frequencies**.
2.  **Data Source:** Select **"Pre-defined Set"**.
3.  **Select Set Object:** Choose `device_set`.
4.  **Weight Variable:** Select `wt`.
5.  Click **Submit**.
    *   *Result:* A table showing the weighted count and percentage of ownership for each device.

### Example 3: Weighted Crosstabs
1.  Navigate to **Analysis > Multiple Response (expss) > Multiple Response Crosstabs**.
2.  **Row Data Source:** "Pre-defined Set" -> `device_set`.
3.  **Column Variable (Group):** Select `gender`.
4.  **Weight Variable:** Select `wt`.
5.  Click **Submit**.
    *   *Result:* A weighted crosstab comparing device ownership by Gender. Notice that the percentages will differ from a standard unweighted count due to the randomized `wt` variable.

## Author

Alfonso Cano Robles (alfonso.cano@correo.buap.mx)

Assisted by Gemini, a large language model from Google.
