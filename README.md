# BERD Academy Open Educational Resources

Link to Website: https://berd-nfdi.github.io/BERD_OER/

This site brings together materials from various sources to support learning, teaching, and exploring data-driven methods.

## How it works

- **`materials.csv`** is the list of all materials (one row per material). It is the single source of truth for tags and links.
- The **pages** (`.qmd` files) contain the written texts. A material appears on a page through a small R block:
  ```r
  source("../utils.R")
  render_tags("ID")
  ```
  This prints the tag badges of the material with that `ID`.
- **`update_locations.R`** runs automatically before every render/preview. It finds all `render_tags("ID")` calls and writes where each material is embedded into the column `location (auto)` of `materials.csv`.
- The **overview table** on the welcome page (`index.qmd`) shows all materials that have a location.
- On every push to `main`, **GitHub Actions** renders and publishes the website and commits the updated `materials.csv` back to the repository.

**Empty `location (auto)` = the material is not on the website yet.**

## Adding a material

### Step 1: Add a row to `materials.csv`

1. **Get the latest version first** (`git pull`), because GitHub Actions also commits to this file. Alternatively, edit the file directly on GitHub (open `materials.csv` → pencil icon).
2. Add one row at the end:

   | Column | Content |
   |---|---|
   | `ID` | Short, unique, no spaces, e.g. `CausalML` |
   | `name` | Name of the course/material |
   | `url` | Link(s) |
   | `type` | e.g. `BERD Academy module`, `self-paced`, `LMU lecture`, `paper` |
   | `data` | e.g. `tabular`, `text`, `images`, or empty |
   | `year` | e.g. `2025` |
   | `material` | e.g. `slides`, `videos`, `jupyter notebook`, `GitHub repository` |
   | `notes` | Anything else, optional |
   | `location (auto)` | **Leave empty** – filled automatically |

   Several values in one cell are separated by `;`, e.g. `slides; videos`.
   Please reuse existing spellings of tags (e.g. `jupyter notebook`, not `Jupyter Notebook`), otherwise they appear as separate tags.
3. Save, commit and push.

**Saving the file correctly:** the file must stay **comma-separated and UTF-8**.
- **Recommended:** LibreOffice Calc (when opening and saving, choose separator `,` and character set `UTF-8`), the GitHub web editor, or VS Code.
- **Excel (German settings) saves CSV files with `;`** – this breaks the file. If it happens, the build stops with the message *"missing columns … saved with ';' instead of ','?"*.

### Step 2: Embed the material on a page

1. Choose the page (`.qmd`) and the section where the material belongs, and write the text and links.
2. Below it, add the R block with the material's `ID`:
   ````
   ```{r tag_ID, results = 'asis', echo = FALSE, warning = FALSE, message = FALSE}
   source("../utils.R")
   render_tags("ID")
   ```
   ````
3. Put it below a heading with an anchor, e.g. `#### Methods {#Methods-DL}`, so the overview table links directly to that section. (Without an anchor, it links to the top of the page.)
4. Preview (`Ctrl+Shift+K` in VS Code): the material now has a location and appears in the overview table. The terminal shows which materials are not on the website yet.
5. Commit and push (this also commits the updated `materials.csv`).

To hide a material again, comment out its block with `<!-- ... -->` – its location will then be empty again.

### Errors the build reports

| Message | Meaning |
|---|---|
| `render_tags() uses IDs that are not in materials.csv` | A page uses an ID that has no row in `materials.csv` (e.g. a typo) |
| `duplicate IDs` | Two rows in `materials.csv` have the same `ID` |
| `missing columns` | `materials.csv` was saved with the wrong separator, or a column was renamed |

### Further things to keep in mind

- New pages or sections must be added to the sidebar in `_quarto.yml`.
- Data type tags should match the headings in `01_data_management/00_data_intro.qmd`. The links of the data type tags on the welcome page are set in `index.qmd` (`data_links`).
