# About BETYdb: Database Description and User's Guide

This book describes the purpose, design, and use of the Biofuel Ecophysiological
Traits and Yields database (BETYdb) and the Ruby on Rails web application that
serves as a front end (also referred to as BETYdb).  The BETYdb database
contains plant trait and yield data that supports research, forecasting, and
decision making associated with agricultural and ecological systems.
While the original focus of BETYdb was agronomy of cellulosic biofuels, the software has
been adopted for wider use. Specifically, as the core database for the [PEcAn Project](https://pecanproject.org){target="_blank"} crop and ecosystem modeling workflow, it is used for ecological research and forecasting.  
BETYdb is also the core database for trait and agronomic metadata in high throughput phenotyping (phenotyping = measuring plants) applications, specifically used for breeding and agronomy trials as the trait database for [TERRA REF](https://terraref.org){target="_blank"}, the Drone Processing Pipeline, and related projects. 
There is an [application](https://github.com/terraref/brapi){target="_blank"} that exports data from BETYdb in a Breeder's API (BrAPI) compliant interface.
The generality of the database has facilitated these extended applications of the underlying software.

Note that this document does not cover the suite of tables used by PEcAn.
These are covered in the [PEcAn documentation](https://pecanproject.github.io/pecan-documentation/master/){target="_blank"}.

## Objectives

A major motivation of the biofuel industry is to reduce greenhouse gas
emissions by providing ecologically and economically sustainable sources
of fuel, thereby reducing dependence on fossil fuel. The goals of this database are to
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

All public data in BETYdb is made available under the [Open Data Commons Attribution License (ODC-By) v1.0](http://opendatacommons.org/licenses/by/1-0/){target="_blank"}. You are free to share, create, and adapt its contents. Data in tables having an an access_level column, and rows where the access_level value is 1 or 2 are not covered by this license but may be available for use with consent.

## Citation

If you use or refer to BETYdb data or software in your research, please cite this paper:

> LeBauer, D., Kooper, R., Mulrooney, P., Rohde, S., Wang, D., Long, S. P., & Dietze, M. C. (2018). BETYdb: a yield, trait, and ecosystem service database applied to second‐generation bioenergy feedstock production. _GCB Bioenergy, 10_, 61–71.  [doi:10.1111/gcbb.12420](https://doi.org/10.1111/gcbb.12420){target="_blank"}

In addition, if you are using _data_ from an instance of BETYdb, please

1. Use the citations associated with each record if the publisher will allow
2. Archive a copy of the data used in the study. The data in BETYdb is not versioned.  
2. Refer to the footer of the instance of BETYdb that you are using for citation information.
   * For example, if you are using data from BETYdb.org, please cite the source of data as:

> LeBauer, David, Rob Kooper, Patrick Mulrooney, Scott Rohde, Dan Wang, Stephen
  P. Long, and Michael C. Dietze. "BETYdb: a yield, trait, and ecosystem service
  database applied to second‐generation bioenergy feedstock production." _GCB
  Bioenergy_ 10, no. 1 (2018):
  61–71. [doi:10.1111/gcbb.12420](https://doi.org/10.1111/gcbb.12420){target="_blank"}

If you are citing the BETYdb _software_, for example the schema, relational
database, web interface, or API, please cite the version used, archived on
[Zenodo](https://zenodo.org/record/593027){target="_blank"}.  For example if you
are using version 4.20, cite this as:

> Scott Rohde, Carl Crott, David LeBauer, Patrick Mulrooney, Rob Kooper, Jeremy
  Kemball, Jimmy Chen, Andrew Shirk, Zhengqi Yang, Max Burnette, Haotian Jiang,
  Yilin Dong, Uday Saraf, Michael Dietze, Chris Black, 2018. BETYdb 4.20 Upgrade
  to Rails
  4.2. [doi:10.5281/zenodo.1199667](https://doi.org/10.5281/zenodo.1199667){target="_blank"}

## Scope


The database contains trait, yield, and ecosystem service data. Because
all plants have the potential to be used as biofuel feedstock, BETYdb
supports data from all plant species. In practice, the species included
in the database reflect available data and the past and present research
interests of contributors. Trait and yield data are provided at the
level of species, with cultivar and clone information provided where
available.

The yield data not only includes end-of-season harvestable yield, it
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
database is from plant genera that are the focus of our current and previous research.
These species include perennial grasses such as miscanthus
(*Miscanthus sinensis*), switchgrass (*Panicum virgatum*), and sugarcane
(*Saccharyn* spp.). BETYdb also includes short-rotation woody species,
including poplar (*Populus* spp.) and willow (*Salix* spp.) and a group
of species that are being evaluated at the energy farm as novel woody
crops. In addition to these herbaceous species, we are collecting data
from a species in an experimental low-input, high-diversity prairie.

An annotated, interactive database schema can be accessed on the BETYdb website by selecting ["Docs --> Schema"](https://www.betydb.org/schemas){target="_blank"}.[^foreign_key_note]

## Design


BETYdb is a relational database that comprehensively documents available trait
and yield data from diverse plant species (Figure
\@ref(fig:abbreviated-schema)).  The underlying structure of BETYdb is designed
to support meta-analysis and ecological modeling. A key feature is the PFT
(plant functional type) table which allows a user to group species for
analysis. On top of the database, we have created a web-portal that targets a
larger range of end users, including scientists, agronomists, foresters, and
those in the biofuel industry.

## Data Entry


The [Data Entry
Workflow](https://pecanproject.github.io/bety-documentation/dataentry/){target="_blank"}
provides a complete description of the data entry process. BETYdb’s web
interface has been developed to facilitate accurate and efficient data
entry. This interface provides logical workflow to guide the user
through comprehensively documenting data along with species, site
information, and experimental methods. This workflow is outlined in the
BETYdb Data Entry Workflow document. Data entry requires a login with `Create`
permissions; this can be obtained by contacting [David
LeBauer](mailto:dlebauer@email.arizona.edu).

## Software


BETYdb uses PostgreSQL for its relational database and Ruby on Rails as its primary web portal. The database and software are deployed on CentOS, RedHat, and Ubuntu Linux servers. In 2018 we began using Docker to streamline deployment, and the [BETYdb repository README](https://github.com/pecanProject/bety#running-bety-using-docker){target="_blank"} provides instructions for deploying BETYdb using Docker.

## List of Tables in the BETY Database

An up-to-date list of the tables in BETYdb along with their descriptions and diagrams of their interrelationships may be found at [https://www.betydb.org/schemas](https://www.betydb.org/schemas){target="_blank"}. [^full_docs]

[^foreign_key_note]: Not all of the columns intended as foreign keys are marked as such in the SQL schema.  Thus some lines (and even some tables) may be missing from the schema diagram.


[^full_docs]: More comprehensive documentation of the schema may be found at
[https://www.betydb.org/db_docs/index.html](https://www.betydb.org/db_docs/index.html){target="_blank"}.
The software used to produce this documentation, SchemeSpy, unfortunately does
not document PostgreSQL check constraints.  Also note that row counts in this
document are not, in general, completely up-to-date.  The complete, definitive
documentation of the schema is the PostgreSQL code used to produce it, which may
be found at
[https://github.com/PecanProject/bety/blob/master/db/structure.sql](https://github.com/PecanProject/bety/blob/master/db/structure.sql){target="_blank"}.
(Note, however, that some BETYdb instances use slightly altered versions of the
official BETYdb database schema.  Sometimes, for example, an instance may add
additional constraints that haven't yet found their way into the official
release.  Another example is the use of materialized views in place of standard
views. These variations occasionally cause problems with the database
synchronization scripts.)

    Some background information about intended constraints may be found in the
spreadsheet at
[https://docs.google.com/spreadsheets/d/1fJgaOSR0egq5azYPCP0VRIWw1AazND0OCduyjONH9Wk/edit?pli=1#gid=956483089](https://docs.google.com/spreadsheets/d/1fJgaOSR0egq5azYPCP0VRIWw1AazND0OCduyjONH9Wk/edit?pli=1#gid=956483089){target="_blank"}
and in a PDF document viewable and downloadable at
[https://www.overleaf.com/articles/constraints-for-betydb/wxptyrksypkx](https://www.overleaf.com/articles/constraints-for-betydb/wxptyrksypkx){target="_blank"}.  These two documents are not necessarily
up-to-date, and not all of the constraints mentioned in them have been
implemented.  In some instances, constraints on new data have been imposed at
the application level but have not yet been imposed on the database itself
because of violations in existing data.
