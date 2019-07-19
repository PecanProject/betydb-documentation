# (PART) Appendix {-}

# Release Notes Template {-}

```
[one line summary]

[full summary]

## Changes Pertinent to PEcAn Users (if applicable)

**_Administrators need to do a database migration._** (if applicable)

See "Database Changes" below.

## Summary of Changes

### New Features

#### [feature 1]

[explanation]

#### [feature 2]

[explanation]

...

### Bug Fixes

#### [fix 1]

[explanation]

#### [fix 2]

[explanation]

...

## Steps Needed for Upgrade

### Database Changes (if applicable)

**_Administrators need to do database migrations!_**

[description of migrations]

The database version for this release is [migration id].

### [special changes, if any]

[explanation]



### Gem Installation (if applicable)

**_Administrators need to run the bundler to install [[[several] new Ruby Gems] (and) [updated versions of existing ones]]._**

[special instructions, if any, including minimizing installation for non-developers]


## Status of RSpec Tests

### All tests continue to pass when run in the default environment and can be run using the command

    ```
    bundle exec rspec
    ```

Complete instructions for setting up the test database and running the RSpec tests are on the Wiki page at https://github.com/PecanProject/bety/wiki/Automated-Tests
```