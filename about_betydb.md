# About BETYdb

## Database Description and User's Guide

This wiki describes the purpose, design, and use of the Biofuel Ecophysiological Traits and Yields database \(BETYdb\). BETYdb is a database of plant trait and yield data that supports research, forecasting, and decision-making associated with the development and production of cellulosic biofuel crops. While the content of BETYdb is agronomic, the structure of the database itself is general and can therefore be used more generally for ecosystem studies.

Note that this document does not cover the suite of tables used by PEcAn. These are covered in the [PEcAn documentation](https://pecan.gitbooks.io/pecan-documentation/content/).

### Objectives

A major motivation of the biofuel industry is to reduce greenhouse gas emissions by providing ecologically and economically sustainable sources of fuel, thereby reducing dependence on fossil fuel. The goals of this database are to provide a clearinghouse of existing research on potential biofuel crops; to provide a source of data on plant ecophysiological traits and yields; and to present ecosystem-scale re-analysis and forecasts that can support the agronomic, ecological, policy, and economic aspects of the biofuel industry. This database will facilitate the scientific advances and assessments that the transition to biofuels will require.

The objectives of this database are to allow other users access to data that has been collected from previously published and ongoing research in a consistent format, and to provide a streamlined interface that allows users to enter their own data. These objectives will support specific research and collaboration, advance agricultural practices, and inform policy decisions. Specifically, BETYdb supports the following uses, allowing users to:

1. Carry out statistical analyses to explore the relationships between traits
2. Identify differences among species and functional groups
3. Access BETYdb from simulation models to look up values for traits and parameters
4. Identify gaps in knowledge about biofuel crop traits and model parameters to aid rational planning of research activities

BETYdb provides a central clearinghouse of biofuel crop physiological traits and yields in a consistently organized framework that simplifies the use of these data for further analysis and interpretation. Scientific applications include the development, assessment, and prediction of crop yields and ecosystem services in biofuel agroecosystems. The database directly supports parameterization and validation of ecological, agronomic, engineering, and economic models. The initial target end-users of BETYdb version 1.0 are users within EBI who aim to support sustainable biofuel production through statistical analysis and ecological modeling. By streamlining the process of data summary, we hope to inspire new scientific perspectives on biofuel crop ecology that are based on a comprehensive evaluation of available knowledge.

All public data in BETYdb is made available under the [Open Data Commons Attribution License \(ODC-By\) v1.0](http://opendatacommons.org/licenses/by/1-0/). You are free to share, create, and adapt its contents. Data in tables having an an access\_level column and in rows where the access\_level value is 1 or 2 are not covered by this license but may be available for use with consent.

Please cite the source of data as:

> LeBauer, David; Dietze, Michael; Kooper, Rob; Long, Steven; Mulrooney, Patrick; Rohde, Gareth Scott; Wang, Dan; \(2010\): Biofuel Ecophysiological Traits and Yields Database \(BETYdb\); Energy Biosciences Institute, University of Illinois at Urbana-Champaign. [http://dx.doi.org/10.13012/J8H41PB9](http://dx.doi.org/10.13012/J8H41PB9)

### Scope

The database contains trait, yield, and ecosystem service data. Because all plants have the potential to be used as biofuel feedstock, BETYdb supports data from all plant species. In practice, the species included in the database reflect available data and the past and present research interests of contributors. Trait and yield data are provided at the level of species, with cultivar and clone information provided where available.

The yield data not only includes end-of-season harvestable yield, it also includes measurements made over the course of the growing season. These yield data are useful in the assessment of historically observed crop yields, and they can also be used in the validation of plant models. Yield data includes peak biomass, harvestable biomass, and the biomass of the crop throughout the growing season.

The trait data represent phenotypic traits; these are measurable characteristics of an organism. The primary objective of the trait data is to allow researchers to model second generation biofuel crops such as miscanthus and switchgrass. In addition, these data enable evaluation of new plant species as potential biofuel crops. Ecosystem service data reflect ecosystem-level observations, and these data are included in the traits table.

### Content

BETYdb includes data obtained through extensive literature review of target species in addition to data collected from the Energy Farm at the University of Illinois, and by our collaborators. The BETYdb database contains trait and yield data for a wide range of plant species so that it is possible to estimate the distribution of plant traits for broad phylogenetic groups and plant functional types.

BETYdb contains data from intensive efforts to find data for specific species of interest as well as from previous plant trait and yield syntheses and other databases. Most of the data currently in the database is from plant genera that are the focus of our current and previous research. These species include perennial grasses such as miscanthus \(_Miscanthus sinensis_\), switchgrass \(_Panicum virgatum_\), and sugarcane \(_Saccharyn_ spp.\). BETYdb also includes short-rotation woody species, including poplar \(_Populus_ spp.\) and willow \(_Salix_ spp.\) and a group of species that are being evaluated at the energy farm as novel woody crops. In addition to these herbaceous species, we are collecting data from a species in an experimental low-input, high-diversity prairie.

An annotated, interactive database schema can be accessed on the BETYdb website by selecting ["Docs --&gt; Schema"](https://www.betydb.org/schemas).

### Design

BETYdb is a relational database that comprehensively documents available trait and yield data from diverse plant species \([Figure 1](about_betydb.md#Figure-1)\). The underlying structure of BETYdb is designed to support meta-analysis and ecological modeling. A key feature is the PFT \(plant functional type\) table which allows a user to group species for analysis. On top of the database, we have created a web-portal that targets a larger range of end users, including scientists, agronomists, foresters, and those in the biofuel industry.

### Data Entry

The [Data Entry Workflow](https://dlebauer.gitbooks.io/betydbdoc-dataentry/content/) provides a complete description of the data entry process. BETYdb’s web interface has been developed to facilitate accurate and efficient data entry. This interface provides logical workflow to guide the user through comprehensively documenting data along with species, site information, and experimental methods. This workflow is outlined in the BETYdb Data Entry Workflow document. Data entry requires a login with `Create` permissions; this can be obtained by contacting [David LeBauer](mailto:dlebauer@illinois.edu).

#### Software

The BETYdb was originally developed in MySQL and later converted to PostgreSQL. It uses Ruby on Rails for its web portal and is hosted on a RedHat Linux Server \(ebi-forecast.igb.illinois.edu\). BETYdb is a relational database designed in a generic way to facilitate easy implementation of additional traits and parameters.

### List of Tables in the BETY Database

An up-to-date list of the tables in BETYdb along with their descriptions and diagrams of their interrelationships may be found at [https://www.betydb.org/schemas](https://www.betydb.org/schemas). 

 Not all of the columns intended as foreign keys are marked as such in the SQL schema. Thus some lines \(and even some tables\) may be missing from the schema diagram.

 More comprehensive documentation of the schema may be found at [https://www.betydb.org/db\_docs/index.html](https://www.betydb.org/db_docs/index.html). The software used to produce this documentation, SchemeSpy, unfortunately does not document PostgreSQL check constraints. Also note that row counts in this document are not, in general, completely up-to-date. The complete, definitive documentation of the schema is the PostgreSQL code used to produce it, which may be found at [https://github.com/PecanProject/bety/blob/master/db/structure.sql](https://github.com/PecanProject/bety/blob/master/db/structure.sql).

Some background information about intended constraints may be found in the spreadsheet at [https://docs.google.com/spreadsheets/d/1fJgaOSR0egq5azYPCP0VRIWw1AazND0OCduyjONH9Wk/edit?pli=1\#gid=956483089](https://docs.google.com/spreadsheets/d/1fJgaOSR0egq5azYPCP0VRIWw1AazND0OCduyjONH9Wk/edit?pli=1#gid=956483089) and in a PDF document viewable and downloadable at [https://www.overleaf.com/2086241dwjyrd](https://www.overleaf.com/2086241dwjyrd). These two documents are not necessarily up-to-date, and not all of the constraints mentioned in them have been implemented. In some instances, constraints on new data have been imposed at the application level but have not yet been imposed on the database itself because of violations in existing data.

