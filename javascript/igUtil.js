/**
* @namespace var igUtil = {};
**/
var igUtil = {};

/**
* @function selectedPKs
* @example igUtil.selectedPKs("customers", "P10_CUSTOMER_IDS", "Please select at least one customer");
**/
igUtil.selectedPKs = function (IGStaticId, returnPageItem, minSelectionMsg) {
  // Get the Interactive Grid View
  var gridView = apex.region(IGStaticId).widget().interactiveGrid("getViews").grid;
  // Get the currently seledcted/checked records from the IG view
  var records = gridView.getSelectedRecords();
  // Create Array of Primary Key Values (getRecordId) from the selected records
  var ids = records.map(function (r) { return gridView.model.getRecordId(r); });
  // Populate APEX Page Item with the selected IDs delimited with a ':'
  apex.item(returnPageItem).setValue(ids.join(":"));

  // Log Debug Messages.
  apex.debug.info("IG Region Static ID: " + IGStaticId);
  apex.debug.info("Return Page Item: " + returnPageItem);
  apex.debug.info("Count Selected IDs: " + ids.length);
  apex.debug.info("Selected IDs: " + ids.join(":"));

  // If minSelectionMsg is populated then user must select at least one item.
  if (ids.length === 0 && minSelectionMsg) {
    // User did not select at least 1 record, so show the error message and return false.
    apex.message.clearErrors();
    apex.message.showErrors([
      {
        type: "error",
        location: "page",
        message: minSelectionMsg,
        unsafe: false
      }]);
    return false;
  } else {
    // All good.
    return true;
  }
}

/**
* @function selectRow
* @example igUtil.selectRow("customers", "P10_CUSTOMER_IDS");
**/
igUtil.selectRow = function (IGStaticId, returnPageItem) {
  var gridView = apex.region(IGStaticId).widget().interactiveGrid("getViews").grid;
  var record = gridView.getSelectedRecords();
  apex.debug.info("IG Region Static ID: " + IGStaticId);
  apex.debug.info("Return Page Item: " + returnPageItem);
  apex.debug.info("Selected records: " + record);
  if (record.length === 0) {
    return false;
  } else {
    var id = gridView.model.getRecordId(record[0]);
    apex.item(returnPageItem).setValue(id);
    return true;
  }
}


igUtil.reselectRows = function (IGStaticId, sourcePageItem) {
  var ids = apex.item(sourcePageItem).getValue().split(":");
  var gridView = apex.region(IGStaticId).widget().interactiveGrid("getViews").grid;
  var records = gridView.model._data.filter(sub => ids.includes(sub[0]))
  gridView.setSelectedRecords(records);
  apex.debug.info("IG Region Static ID: " + IGStaticId);
  apex.debug.info("Source Page Item: " + sourcePageItem);
  apex.debug.info("Selected records: " + ids);
}


