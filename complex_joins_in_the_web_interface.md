# Complex Joins in the Web Interface

Several edit pages have sections for editing associations that use multi-select boxes with huge lists in them.  These are being replaced by a search box the will display a list of of entities from the associated table and offer the user the opportunity toggle the "linked" status of each displayed entity--that is, unlink linked entities and link unlinked entities.

Here is a list of files that need to be revised.  We'll call the primary table being edited "primary" and the associated table "associate".

* `primary_controller.rb`
* `_edit_primary_associate.html.erb`
* `routes.rb`

These files need to be added:

* `_associate_tbody.html.erb`
* `search_associate.js.erb`
* `edit.js.erb`
* `add_primary_associate.js.erb`
* `rem_primary_associate.js.erb`

[Note: The convention for Rails join tables is to alphabetize the names, and this convention was also used in naming some of the templates and corresponding actions.  To maintain this convention, some of the file names above should be altered if `primary` follows `associate` alphabetically.  In this case, the file names to use will be `edit_associate_primary.html.erb`, `add_associate_primary.js.erb`, and `rem_associate_primary.js.erb` in place of the names given above, and the names of actions and references to these files in the files themselves will have to be adjusted accordingly.]

Here are step-by-step instructions for making the required changes.  The changes in place for editing sites associated with a citation may serve as a model (see the controller file `citations_controller.rb` and the template files in `app/views/citations`; in the case of the template files, these can simply be copied and a search and replace done to replace the primary and associated table names (use the singular form when doing this):

1. Revise the `_edit_primary_associate.html.erb` partial (copy e.g. `app/views/citations/_edit_citations_sites.html.erb` and replace `citation` and `site` with the appropriate strings).
2. Make the `_associate_tbody.html.erb` partial.
3. Alter the `routes.rb` file, adding a member route of the form `get :search_associate` to the resources for `primary`.
4. Add a `search_associate.js.erb` JavaScript template.
5. Add a search (`search_associate`) action to the controller.
6. If needed, add a search scope to the model for `associate` (or write the action in step 5 in a way so that one isn't required).
7. At this point searching associates on the edit page should work. (If needed, add an instance variable for the associated collection to the `edit` action.)
8. Add an `edit.js.erb` Javascript template.
9. Alter the `edit` action of the controller so that it handles `js` format.  (`render layout` should be `false`, and additional template variables may have to be defined in the action.)  **Also, alter the update action to be ensure that if it renders the edit template on error, it has the variables it needs.**
10. At this point the "Show only related ..." that appears after doing a search should be functional.
11. In `routes.rb`, rename the `:edit_primary_associate` route to `:add_primary_associate` and change the method from `post` to `get`.
12. Rename the corresponding action in the controller and revise this action (use `CitationsController#add_citations_sites` as a model).
13. Add the `add_primary_associate.js.erb` JavaScript template.
14. At this point, linking an associated entity to the primary entity by clicking on the `+` sign should work.
15. In the controller, revise the `rem_primary_associate` action (use `CitationsController#rem_citations_sites` as a model).
16. Add the `rem_primary_associate.js.erb` JavaScript template.
17. At this point, unlinking an associated entity to the primary entity by clicking on the `X` should work.  The "Update" link that appears next to the "Existing Sites Relationships" table caption after unlinking an associate should now work and should erase from view the entity you just unlinked.

