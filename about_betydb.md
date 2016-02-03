# About BETYdb

# Database Description and User's Guide 

This wiki describes the purpose, design, and use of the Biofuel
Ecophysiological Traits and Yields database (BETYdb). BETYdb is a
database of plant trait and yield data that supports research,
forecasting, and decision making associated with the development and
production of cellulosic biofuel crops. While the content of BETYdb is
agronomic, the structure of the database itself is general and can
therefore be used more generally for ecosystem studies.

Note that this document does not cover the suite of tables used by PEcAn. 
These are covered in the [[ PEcAn documentation | https://github.com/PecanProject/pecan/wiki ]].

## Objectives

A major motivation of the biofuel industry is to reduce greenhouse gas
emissions by providing ecologically and economically sustainable sources
of fuel and dependence on fossil fuel. The goals of this database are to
provide a clearinghouse of existing research on potential biofuel crops;
to provide a source of data on plant ecophysiological traits and yields;
and to present ecosystem-scale re-analysis and forecasts that can
support the agronomic, ecological, policy, and economic aspects of the
biofuel industry. This database will facilitate the scientific advances
and assessments that the transition to biofuels will require.


The objectives of this database are to allow other users access to data
that has been collected from previously published and ongoing research
in a consistent format, and to provide a streamlined interface that
allows users to enter their own data. These objectives will support
specific research and collaboration, advance agricultural practices, and
inform policy decisions. Specifically, BETYdb supports the following
uses, allowing users to:

1.  Carry out statistical analyses to explore the relationships between
    traits

2.  Identify differences among species and functional groups

3.  Access BETYdb from simulation models to look up values for traits
    and parameters

4.  Identify gaps in knowledge about biofuel crop traits and model
    parameters to aid rational planning of research activities

BETYdb provides a central clearinghouse of biofuel crop physiological
traits and yields in a consistently organized framework that simplifies
the use of these data for further analysis and interpretation.
Scientific applications include the development, assessment, and
prediction of crop yields and ecosystem services in biofuel
agroecosystems. The database directly supports parameterization and
validation of ecological, agronomic, engineering, and economic models.
The initial target end-users of BETYdb version 1.0 are users within EBI
who aim to support sustainable biofuel production through statistical
analysis and ecological modeling. By streamlining the process of data
summary, we hope to inspire new scientific perspectives on biofuel crop
ecology that are based on a comprehensive evaluation of available
knowledge.

All public data in BETYdb is made available under the [Open Data Commons Attribution License (ODC-By) v1.0](http://opendatacommons.org/licenses/by/1-0/). You are free to share, create, and adapt its contents. Data in tables having an an access_level column and in rows where the access_level value is 1 or 2 are not covered by this license but may be available for use with consent.

Please cite the source of data as:

> LeBauer, David; Dietze, Michael; Kooper, Rob; Long, Steven; Mulrooney, Patrick; Rohde, Gareth Scott; Wang, Dan; (2010): Biofuel Ecophysiological Traits and Yields Database (BETYdb); Energy Biosciences Institute, University of Illinois at Urbana-Champaign. http://dx.doi.org/10.13012/J8H41PB9



## Scope


The database contains trait, yield, and ecosystem service data. Because
all plants have the potential to be used as biofuel feedstock, BETYdb
supports data from all plant species. In practice, the species included
in the database reflect available data and the past and present research
interests of contributors. Trait and yield data are provided at the
level of species, with cultivar and clone information provided where
available.

The yield data not only includes end-of-season harvestable yield, but
also includes measurements made over the course of the growing season.
These yield data are useful in the assessment of historically observed
crop yields, and they can also be used in the validation of plant
models. Yield data includes peak biomass, harvestable biomass, and the
biomass of the crop throughout the growing season.

The trait data represent phenotypic traits; these are measurable
characteristics of an organism. The primary objective of the trait data
is to allow researchers to model second generation biofuel crops such as
miscanthus and switchgrass. In addition, these data enable evaluation of
new plant species as potential biofuel crops. Ecosystem service data
reflect ecosystem-level observations, and these data are included in the
traits table.

## Content

BETYdb includes data obtained through extensive literature review of
target species in addition to data collected from the Energy Farm at the
University of Illinois, and by our collaborators. The BETYdb database
contains trait and yield data for a wide range of plant species so that
it is possible to estimate the distribution of plant traits for broad
phylogenetic groups and plant functional types.

BETYdb contains data from intensive efforts to find data for specific
species of interest as well as from previous plant trait and yield
syntheses and other databases. Most of the data currently in the
database is from plant groups that are the focus of our current research
([Table 1](#Table-1)). These species include perennial grasses, such as miscanthus
(*Miscanthus sinensis*) switchgrass (*Panicum virgatum*), and sugarcane
(*Saccharyn* spp.). BETYdb also includes short-rotation woody species,
including poplar (*Populus* spp.) and willow (*Salix* spp.) and a group
of species that are being evaluated at the energy farm as novel woody
crops. In addition to these herbaceous species, we are collecting data
from a species in an experimental low-input, high diversity prairie.

An annotated, interactive schema can be accessed on the website by selecting ["docs --> schema"](https://www.betydb.org/schemas)

<a name="Table-1"> </a>
**Table 1**: Data from the targeted species-specific data collection for BETYdb. Data are summarized by genus for the top seven genera, and the rest of the data are summarized by plant function type.   
![Alt text] (figures/ug table 1.png "Table 1")   

<a name="Figure-1"></a>  
![Alt text] (figures/ug figure 1.png "Figure 1")  
**Figure 1**: Abbreviated schema for BETYdb.  Up-to-date versions of this figure and of the other figures and tables in this document may be found at https://www.betydb.org/schemas. 

## Design


BETYdb is a relational database that comprehensively documents available
trait and yield data from diverse plant species ([Figure 1](#Figure-1)). The underlying
structure of BETYdb is designed to support meta-analysis and ecological
modeling. A key feature is the PFT (plant functional type) table which
allows a user to group species for analysis. On top of the database, we
have created a web-portal that targets a larger range of end users,
including scientists, agronimists, foresters, and those in the biofuel
industry.

## Data Entry


The [Data Entry
Workflow](https://authorea.com/users/5574/articles/6800/_show_article)
provides a complete description of the data entry process. BETYdb’s web
interface has been developed to facilitate accurate and efficient data
entry. This interface provides logical workflow to guide the user
through comprehensively documenting data along with species, site
information, and experimental methods. This workflow is outlined in the
BETYdb Data Entry Workflow document. Data entry requires a login with `Create`
permissions; this can be obtained by contacting [David
LeBauer](mailto:dlebauer@illinois.edu).

## Tables


DETYdb is designed as a relational database, somewhat normalized as shown in the structure diagram [Figure 1] (#Figure-1). Each table has a primary key
field, `id`, which serves as surrogate key, a unique identifier for each row in the table.  Most tables have a natural key defined as well, by which rows can be uniquely identified by real-world attributes.
In addition, most tables have a `created_at` and an `updated_at` column to record row-insertion and update timestamps, and the
traits and yields tables each have a `user_id` field to record the user
who originally entered the data.

A complete list of tables along with short descriptions is provided in [Table 2](#Table-2), and a comprehensive
description of the contents of each table is provided below. **Note: An up-to-date list of the tables in BETYdb along with their descriptions and diagrams of their interrelationships may be found at https://www.betydb.org/schemas.**

<a name="Table-2"></a>  
![Alt text] (figures/ug table 2.png "Table 2") 


## Table and field naming conventions


Each table is given a name that describes the information that it
contains. For example, the table containing trait data is called
`traits`, the table containing yield data is `yields`, and so on. Each
table also has a *primary key*; the primary key is always `id`, and the
primary key of a specific table might be identified as `yields.id` . One
table can reference another table using a *foreign key*; the foreign key
is given a name using the singular form of the foreign table, and
underscore, and id, e.g. `trait_id` or `yield_id`.

In some cases, two tables can have multiple references to one another,
known as a ’many to many’ or ’m:n’ relationship. For example, one
citation may contain data from many sites; at the same time, data from a
single site may be included in multiple citations. Such relationships
use join tables (also known as "association tables" or "junction tables"). Join tables (e.g. [Table 4](#Table-4), [Table 5](#Table-5), [Table 10](#Table-10), [Table 12](#Table-12), [Table 13](#Table-13))
combine the names of the two tables being related. For
example, the table used to link `citations` and `sites` is named
`citations_sites`. These join tables have two foreign keys (`citation_id` and `site_id` in this example) which together uniquely identify a row of the table (and thus constitute a _candidate key_).  (For various implementational reasons, these tables also have a surrogate key named `id`, but in general such a key is extraneous.)  

While foreign key columns are identified implicitly by the naming convention whereby such columns end with the suffix `_id`, foreign keys can be made explicit by imposing a _foreign-key constraint_ at the database level.  Such a constraint identifies the table and column which the foreign key refers to and in addition guaranties that a row with the required value exists.  Thus, if there is a foreign-key constraint saying that the column `yields.citation_id` refers to `citations.id`, then if there is a row in the yields table where `cititation_id = 9`, there must also be a row in the citations table where `id = 9`.  Explicit foreign keys show up in the [schema](https://www.betydb.org/schemas) documentation as an entry in the _References_ column of table listing and as a line between tables in the schema diagrams.

### Data Tables

The two data tables, **traits** and **yields**, contain the primary data
of interest; all of the other tables provide information associated with
these data points. These two tables are structurally very similar as can
be seen in [Table 17](#Table-17) and [Table 20](#Table-20).

#### traits

The **traits** table contains trait data ([Table 17](#Table-17)). Traits are measurable
phenotypes that are influenced by a plants genotype and environment.
Most trait records presently in BETYdb describe tissue chemistry,
photosynthetic parameters, and carbon allocation by plants.

#### yields

The **yields** table includes aboveground biomass in units of Mg per
ha ([Table 20](#Table-20)). Biomass harvested in the fall and winter generally
represents what a farmer would harvest, whereas spring and summer
harvests are generally from small samples used to monitor the progress
of a crop over the course of the growing season. Managements associated
with Yields can be used to determine the age of a crop, the
fertilization history, harvest history, and other useful information.

### Auxillary Tables


#### sites

Each site is described in the **sites** table ([Table 15](#Table-15)). A site can have
multiple studies and multiple treatments. Sites are identified and
should be used as the unit of spatial replication; treatments are used to
identify independent units within a site, and these can be compared to
other studies at the same site with shared management. "Studies" are
not identified explicitly but independent studies can be identified via
shared management entries at the same site.

#### treatments

The **treatments** table provides a categorical identifier of a study’s
experimental treatments, if any ([Table 18](#Table-18)).

Any specific information such as rate of fertilizer application should
be recorded in the managements table. A treatment name is used
as a categorical (rather than continuous) variable, and the name relates
directly to the nomenclature used in the original citation. The
treatment name does not have to indicate the level of treatment used in
a particular treatment&mdash;if required for analysis, this information is
recorded as a management.

Each study includes a control treatment; when there is no experimental
manipulation, the treatment is considered ’observational’ and listed as
"control". In studies that compare plant traits or yields across different
genotypes, site locations, or other factors that are built in to the
database, each record is associated with a separate cultivar or site so
these are not considered treatments.

For ambiguous cases, the control treatment is assigned to the treatment
that best approximates the background condition of the system in its
non-experimental state; for this reason, a treatment that approximates
conventional agronomic practice may be labeled ’control’.

#### managements

The **managements** table provides information on management types,
including planting time and methods, stand age, fertilization,
irrigation, herbicides, pesticides, as well as harvest method, time and
frequency.

The **managements** and **treatments** tables are linked through the
`managements_treatments` table ([Table 10](#Table-10)).

Managements are distinct from treatments in that a management is used to
describe the agronomic or experimental intervention that occurs at a
specific time and may have a quantity whereas _treatment_ is a categorical
identifier of an experimental group. Managements include actions that
are done to a plant or ecosystem&mdash;for example the planting density or
rate of fertilizer application.

In other words, managements are the way a treatment becomes quantified.
Each treatment can be associated with multiple managements. The
combination of managements associated with a particular treatment will
distinguish it from other treatments. Each management may be associated
with one or more treatments. For example, in a fertilization experiment,
planting, irrigation, and herbicide managements would be applied to all
plots but the fertilization will be specific to a treatment. For a
multi-year experiment, there may be multiple entries for the same type
of management, reflecting, for example, repeated applications of
herbicide or fertilizer.

#### covariates

The **covariates** table is used to record one or more covariates
associated with each trait record ([Table 6](#Table-6)). Covariates generally indicate the
environmental or experimental conditions under which a measurement was
made. The definition of specific covariates can be found in the
**variables** table ([Table 19](#Table-19)). Covariates are required for many of the traits
because without covariate information, the trait data will have limited
value.

The most frequently used covariates are the temperature at which some
respiration rate or photosynthetic parameter was measured. For example,
photosynthesis measurements are often recorded along with irradiance,
temperature, and relative humidity.

Other covariates include the size or age of the plant or plant part
being measured. For example, root respiration is usually measured on
fine roots, and if the authors define fine root as < 2mm, the covariate
`root_diameter_max` has a value of 2.

#### pfts

The plant functional type (PFT) table **pfts** is used to group plants
for statistical modeling and analysis. Each record in **pfts** contains
a PFT that is linked to a subset of species in the **species** table.
This relationship requires the lookup table **pfts\_species** ([Table 13](#Table-13)).
Furthermore, each PFT can be associated with a set of trait prior
probability distributions in the **priors** table ([Table 14](#Table-14)). This relationship
requires the lookup table **pfts\_priors** ([Table 12](#Table-12)).

In many cases, it is appropriate to use a pre-defined default PFT (for example
`tempdecid` is temperate deciduous trees). In other cases, a user can
define a new PFT to query a specific set of priors or subset of species.
For example, there is a PFT for each of the functional types found at
the EBI Farm prairie. Such project-specific PFTs can be defined as
`` `projectname`.`pft` `` (i.e. `ebifarm.c4grass` instead of `c4grass`).

#### variables

The **variables** table includes definitions of different variables used
in the traits, covariates, and priors tables ([Table 19](#Table-19)). Each variable has a
`name` field and is associated with a standardized value for `units`.
The `description` field provides additional information or context about
the variable.

### Join Tables


Join tables are required when each row in one table may be related
to many rows in another table, and vice-versa; this is called a ’many-to-many’ relationship.

#### citations\_sites

Because a single study may use multiple sites and multiple studies may
use the same site, these relationships are tracked in the
**citation\_sites** table ([Table 4](#Table-4)).

#### citations\_treatments

Because a single study may include multiple treatments and each
treatment may be associated with multiple citations, these relationships
are measured in the **citations\_treatments** table ([Table 5](#Table-5)).

#### managements\_treatments

It is clear that one treatment may have many managements, e.g. tillage,
planting, fertilization. It is also important to note that any
managements applied to a control plot should, by definition, be
associated with all of the treatments in an experiment; this is why the
many-to-many association table **managements\_treatments** is required.

#### pfts\_priors

The **pfts\_priors** table allows a many-to-many relationship between
the **pfts** and **priors** tables ([Table 12](#Table-12)). This allows each pft to be
associated with multiple priors and each prior to be associated with
multiple pfts.

#### pfts\_species

The **pfts\_species** table allows a many-to-many relationship between
the **pfts** and **species** tables ([Table 13](#Table-13)).

## Acknowlegments

BETYdb is a product of the Energy Biosciences Institute at the
University of Illinois at Urbana-Champaign. Funding for this research
was provided by BP plc through a grant to the Energy
Biosciences Institute. We gratefully acknowledge the great effort of
other researchers who generously made their own data available for
further study.

## Appendix


### Full Schema: Enhanced Entity-Relationship Model

 **Note: An up-to-date list of the tables in BETYdb along with their descriptions and diagrams of their interrelationships may be found at https://www.betydb.org/schemas.**

[Figure 3](#Figure-3) provides a visualization of the complete schema, including
interrelationships among tables, of the biofuel database.

<a id="Figure-3"></a>  
![Alt text] (figures/ug figure 3.png "figure 3")   
**Figure 3**: Full schema of BETYdb, showing all tables and relations on the data base


[Figure 3.1](#Figure-3.1) provides a visualization of the complete schema, including
interrelationships among tables, of the biofuel database.

<a name="Figure 3.1" style="width: 600 height: 400"></a>  
![Alt text] (figures/models_brief_small.png "figure 3.1")   
**Figure 3**: View of Database from perspective of Ruby

### Software


The BETYdb was originally developed in MySQL and later converted to PostgreSQL.  It uses Ruby on Rails for its web portal and is hosted on a RedHat Linux Server (ebi-forecast.igb.uiuc.edu). 
BETYdb is a relational database designed in a generic way to facilitate easy
implementation of additional traits and parameters.

## List of Tables in the BETY Database

An up-to-date list of the tables in BETYdb along with their descriptions and diagrams of their interrelationships may be found at https://www.betydb.org/schemas.