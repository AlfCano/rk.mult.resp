# rk.mult.resp: Multiple Response Analysis for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3-green.svg)
![R Version](https://img.shields.io/badge/R-%3E%3D%203.0.0-lightgrey.svg)

This package provides a suite of RKWard plugins for analyzing **Multiple Response Sets** (also known as "Check-all-that-apply" questions). Powered by the **`expss`** package, it brings SPSS-style tables and logic to RKWard, allowing you to define, tabulate, and cross-tabulate complex survey data without writing code.

## Features / Included Plugins

This package installs a new submenu in RKWard: **Analysis > Multiple Response (expss)**, containing the following tools:

*   **Multiple Response Frequencies:**
    *   Calculate counts and percentages for response sets.
    *   Supports **Dichotomies** (e.g., columns contain 0/1 or Yes/No).
    *   Supports **Categories** (e.g., "Mention up to 3 brands", distributed across 3 columns).

*   **Multiple Response Crosstabs:**
    *   Cross-tabulate a Multiple Response Set (Rows) against a categorical Grouping variable (Columns).
    *   Automatically calculates Column Percentages.

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
To test the plugins, copy and run this code in your RKWard console to create a simulated dataset containing both Dichotomy and Category style questions:

```R
survey_data <- data.frame(
  id = 1:10,
  gender = c("Male", "Female", "Female", "Male", "Male", "Female", "Male", "Female", "Male", "Female"),
  
  # --- SET A: Dichotomies (Yes/No style) ---
  # Question: "Which devices do you own?" (1 = Yes, 0 = No)
  device_phone  = c(1, 1, 1, 1, 1, 1, 0, 1, 1, 1),
  device_tablet = c(0, 1, 1, 0, 0, 1, 0, 1, 0, 1),
  device_laptop = c(1, 1, 0, 1, 1, 0, 1, 1, 1, 0),
  
  # --- SET B: Categories (Multiple Choice style) ---
  # Question: "Mention up to 3 favorite colors" (1=Red, 2=Blue, 3=Green, 4=Yellow)
  fav_color_1 = c(1, 2, 1, 3, 4, 2, 3, 1, 2, 3),
  fav_color_2 = c(2, 3, NA, 1, 3, NA, 1, 2, 4, 1),
  fav_color_3 = c(NA, 4, NA, 2, NA, NA, NA, 3, NA, NA)
)
```

### Example 1: Frequencies (Dichotomies)
1.  Navigate to **Analysis > Multiple Response (expss) > Multiple Response Frequencies**.
2.  **Variables in Set:** Select `device_phone`, `device_tablet`, and `device_laptop`.
3.  **Set Type:** Select **"Dichotomies (Counted value)"**.
4.  **Counted Value:** Enter `1`.
5.  **Set Label:** Type "Devices Owned".
6.  Click **Submit**.
    *   *Result:* A table showing the ownership stats. Total percentages may exceed 100% because users can own multiple devices.

### Example 2: Frequencies (Categories)
1.  Navigate to **Analysis > Multiple Response (expss) > Multiple Response Frequencies**.
2.  **Variables in Set:** Select `fav_color_1`, `fav_color_2`, and `fav_color_3`.
3.  **Set Type:** Select **"Categories (Multiple columns)"**.
4.  **Set Label:** Type "Favorite Colors".
5.  Click **Submit**.
    *   *Result:* A table counting the occurrences of values (1, 2, 3, 4) across the three columns.

### Example 3: Crosstabs
1.  Navigate to **Analysis > Multiple Response (expss) > Multiple Response Crosstabs**.
2.  **Row Variables (The Set):** Select the three `device_` variables.
3.  **Column Variable (Group):** Select `gender`.
4.  **Set Type:** "Dichotomies", Counted Value: `1`.
5.  Click **Submit**.
    *   *Result:* A comparison table showing device ownership broken down by Gender.

## Author

Alfonso Cano Robles (alfonso.cano@correo.buap.mx)

Assisted by Gemini, a large language model from Google.
