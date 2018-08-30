# Database Constraints

BETYdb contains database level constraints. Building constraints into the SQL schema provides a way of explicitly defining the meaning of the database model and its intended functionality.

## Types of Constraints

1. **Value** constraints include:
   * range constraints on continuous variables
   * “enum” constraints on, for example, state or country designations; this is a form of normalization \(“US” and “USA” should be folded into a common designation\); forms utilized by SELECT controls should perhaps be favored
   * consistency constraints: for example \(year, month, day\) can’t be \(2001, 2, 29\); or city-\(state\)-country vs. latitude-longitude \(this may be hard, but some level of checking may not be too difficult; for example, “select \* from sites where country in \('US', 'United States', 'USA'\) and lon &gt; 0;” shouldn’t return any rows\)
2. **Foreign key** constraints
   * Prevents accidental deletion of meta-data records in lookup tables
   * Prevents entry of primary data without contextual information required to interpret the data
3. **Non-NULL** constraints
   * Constrains which fields can not be empty
4. **Uniqueness** constraints 
   * These define what makes a row unique, by designating a 'natural key' - a combination of fields that make a row unique \(distinct from primary keys that are used in cross-table joins\).

All constraints are defined in the database schema, [`db/production_structure.sql`](https://github.com/PecanProject/bety/blob/master/db/production_structure.sql)

## Value Constraints \(including some NOT NULL constraints\)

### Global

* Text fields should not have leading or trailing white spaces. \(Are there any fields for which this is not the case?\)  

  This can be checked with

  ```text
      CHECK(TRIM(FROM <columnname>) = <columnname>)
  ```

  Probably sequences of two or more consecutive whitespace characters should be forbidden as well except for various free-form textual columns such as `traits.notes`.  This can be checked with

  ```text
      CHECK(REGEXP_REPLACE(TRIM(FROM <columnname>), ' +', ' ') = <columnname>)
  ```

  For convenience, we should probably define a function so we can just do something like

  ```text
      CHECK(is_normalized(<columnname>))
  ```

  .

### covariates:

* Check that `level` is in the range corresponding to variable referenced by `variable_id`.
* Check that `n` is positive \(or &gt; 1 ?\) if it is not NULL.
* Check that `statname` and `stat` are either both NULL or both non-NULL.  \(Alternatively, ensure that `statname` is non-NULL and that it equals the empty string if and only if `stat` is NULL.\)
* Check that `statname` is one of "SD", "SE", "MSE", "95%CI", "LSD", "MSD" or possibly "".  Consider creating an ENUM data type for this.

### managements:

* mgmttype: Constrain to one of the values in the web interface’s dropdown.  \(Is there any reason not to store these in the variables table, or in a separate lookup table?  If we record units and range restrictions, this would be useful.  On the other hand, if we continue to use a static list of management types, we should create a new ENUM type in the database to enumerate the allowed values.
* level: This should always be non-negative \(except in the case that we want to use the special value -999 for mgmttypes where a level has no meaning; if so, we should also constrain level to be non-NULL\).
* units: Should be constrained to a known set of values—in fact, on a per mgmttype basis; currently there are several varying designations for the same unit in a number of cases
* dateloc: Should be constrained to specific values.  Since there is a value \(9\) designated as meaning "no data", this column should be constrained to be NOT NULL.  We should perhaps constraint this column to have this value if `date` is NULL.
* All values of citation\_id in managements should also be associated with treatment via citations\_treatments table.  Does thie mean: The management should be associated with \(at least\) one of the treatments associated with the citation specified by `citation_id`?

### species:

* Ensure scientificname LIKE CONCAT\(genus, ‘ ‘, species, ‘%’\)
* Ensure genus is capitalized \(and consists of a single word?\).

### sites:

* lat \(replaced by geometry\)
* lon \(replaced by geometry\)
* som: 0 – 100
* mat: range: -50, 150 
* masl:  \(replaced by geometry\)
* map: Minimum is zero.  Maximum = ?
* local\_time: Range should be -12 to +12.  This might more aptly be called timezone.  A comment should clarify the meaning; I assume it should mean something like "the number of hours local standard time is ahead of GMT".  Some kind of check might be possible to ensure consistence with the longitude.
* sand\_pct, clay\_pct: These both have range 0--100, and sand\_pct + clay\_pct should be &lt;= 100.
* sitename: Unique and non-null \(see below\); also, ensure it does not have leading or trailing white space and no internal sequences of 2 or more consecutive spaces.  This will make the uniqueness constraint more meaningful.  \(A similar white space constraint should apply to all textual keys in all tables.\)

### traits:

It isn’t clear what a natural key would be, but it would probably involve several foreign key columns. Perhaps \(site\_id, specie\_id, cultivar\_id, treatment\_id, variable\_id, and some combination of date and time fields. But it is important to have some sort of uniqueness constraint other than just the default unique-id constraint. For example, if the web-interface user accidentally presses the Create button on the New Trait page twice, two essentially equal trait rows will be created \(they will differ only in the id and timestamp columns\). See Uniqueness Constraints below!

* date, dateloc, time, timeloc, date\_year, date\_month, date\_day, time\_hour, time\_minute: Check date and time fields consistency: For example, if dateloc is 91—97, date and date\_year should both be NULL \(but maybe old data doesn’t adhere to this?\).  If date\_year, date\_month, or date\_day is NULL, date should be NULL as well.  Also, dateloc and timeloc should be constrained to certain meaningful values.  \(See comment above on managements.dateloc.\)
* mean: Check mean is in the range corresponding to the variable referenced by variable\_id.
* n, stat, statname: n should always be positive; if n = 1, statname should be NULL.  statname should be one of a specified set of values.  \(See comments above on covariates.stat and covariates.statname.\)
* specie\_id and cultivar\_id need to be consistent with one another.
* access\_level: Range is 1--4.

### treatments:

* name: Possibly standardize capitalization of names \(easiest would be to have all words in all names not capitalized except for proper names and unit names where appropriate; this would convey the most information because \(e.g.\) author names would stand out from other words\).  This would need to be done manually to avoid converting proper names to lowercase.  As stated below, names should be unique within a citation and site pair; standardizing capitalization will make this constraint more meaningful.
* definition: Treat captitalization similarly to that for names.
* control: There can be more than one control treatment per citation \(currently there are\).  Below in the uniqueness section, it is stated that there can be only one control for a given citation _and site_.
* Since \(as stated below\) names should be unique within a citation and site pair, standardizing capitalization will make this constraint more meaningful.

### users:

* login: Enforce any constraints required by the Rails interface.
* email: Constrain to valid email addresses.
* country: Constrain to valid country names.
* area: This currently isn't very meaningful.  Perhaps this should be an ENUM.  Alteratively, it could be constraint to be some category word followed by free-form text.
* access\_level: Range is 1 - 4.
* page\_access\_level: Range is 1 - 4.
* postal\_code: Ideally, this should be constrained according to the country.  Since most users are \(currently\) from the U.S., we could at least constraint U.S. postal codes to "NNNNNN" or "NNNNNN-NNNN".

### yields: \[see also traits constraints\]

* mean: mean should be in the range of plausible yield values.

## Foreign Key Constraints

All foreign key constraints follow the form `table_id references tables`, following Ruby style conventions.

A [Github Gist](https://gist.github.com/dlebauer/12d8d9ed1b2965301d64) contains a list of foreign key constraints to be placed on BETYdb. The foreign keys are named using the form `fk_foreigntable_lookuptable_1` where the foreigntable has the foreign key.

## Non Null Constraints

This is a list of fields that should not be allowed to be null. In all cases, the primary key should not be null. For many-to-many relationship tables, the foreign keys should be non-null.

* citations: author, year, title
* covariates: trait\_id, variable\_id
* cultivars: specie\_id, name
* dbfiles: file\_name, file\_path, container\_type, container\_id, machine\_id
* ensembles: workflow\_id
* formats: dataformat
* formats\_variables: ?
* inputs: name, access\_level, format\_id
* likelihoods: run\_id, variable\_id, input\_id
* machines: hostname
* managements: date, management\_type
* methods: name, description, citation\_id
* models: model\_name, model\_path, revision, model\_type
* pfts: definition, name
* posteriors: pft\_id, format\_id
* priors: phylogeny, variable\_id, distn, parama, paramb
* runs: model\_id, site\_id, start\_time, finish\_time, outdir, outprefix, setting, parameter\_list, started\_at, ensemble\_id \(note: finished\_at will not be available when record is created\)
* sites: lat, lon, sitename, greenhouse
* species: genus, species, scientificname
* traits: specie\_id, citation\_id, treatment\_id, mean, variable\_id, checked, access\_level
* treatments: name, control
* users: login, name, email, crypted\_password, salt, access\_level, page\_access\_level, apikey
* variables: namem, units 
* workflows: folder, started\_at, site\_id, model\_id, hostname, params, advanced\_edit, start\_date, end\_date 
* yields: specie\_id, citation\_id, treatment\_id, mean, variable\_id, checked, access\_level

## Uniqueness constraints

Uniqueness constraints are "natural keys", i.e. combinations of fields that should be unique within a table. Ideally, each table would have a natural key, but a table may have 0, 1, or many uniqueness constraints.

For many-to-many relationship tables, the foreign key pairs should be unique; these should be implemented but are not listed here for brevity.

* citations: author, year, title
* covariates: trait\_id, variable\_id
* cultivars: specie\_id, name
* dbfiles: file\_name, file\_path, machine\_id
* dbfiles: container\_type, container\_id
* formats\_variables: ?
* formats: site\_id, start\_date, end\_date, format\_id
* likelihoods: run\_id, variable\_id, input\_id
* machines: hostname
* managements: date, management\_type
* methods: name, citation\_id
* models: model\_path
* pfts: name
* posteriors: pft\_id
* priors: phylogeny, variable\_id, distn, parama, paramb
* priors: phylogeny, variable\_id, notes
* runs: \(?\) model\_id, site\_id, start\_time, finish\_time, parameter\_list, ensemble\_id
* sites: lat, lon, sitename
* species: scientificname \(not genus, species because there may be multiple varieties\)
* traits: site\_id, specie\_id, citation\_id, cultivar\_id, treatment\_id, date, time, variable\_id, entity\_id, method\_id, date\_year, date\_month, date\_day, time\_hour, time\_minute
* treatments: 
  * for a given citation, name should be unique; 
  * for a given citation and site, there should be only one control
* users: \(each of the following fields should be independently unique from other records\) 
  * login
  * email
  * crypted\_password
  * salt 
  * apikey
* variables: name
* workflows: site\_id, model\_id, params, advanced\_edit, start\_date, end\_date
* yields: site\_id, specie\_id, citation\_id, cultivar\_id, treatment\_id, date, entity\_id, method\_id, date\_year, date\_month, date\_day

## Technical Note

**Database level constraints violates Ruby's "Active Record"** approach.

The [Rail Guide on Database Migrations](http://guides.rubyonrails.org/migrations.html#active-record-and-referential-integrity) suggests

> The Active Record way claims that intelligence belongs in your models, not in the database. As such, features such as triggers or foreign key constraints, which push some of that intelligence back into the database, are not heavily used.

In order to add database constraints we moved from using `db/schema.rb` to `db/structure.sql`, so that the schema is stored in SQL rather than in Ruby.

Given that the Ruby web application is only one of the ways in which we use the database, it seems reasonable to go with the SQL database-level constraints.

The `db/structure.sql` approach is more straightforward, allows the database to exist independently of its Rails framework, and provides more flexibility.

