
var pesele = apex.item('P1011_PESEL_SELECTED').getValue().split(':')
var rekordy =  apex.region('osoby_ig').widget().interactiveGrid("getViews").grid.model._data.filter(sub => pesele.includes(sub[0]))

apex.region('osoby_ig').widget().interactiveGrid("getViews").grid.setSelectedRecords(
   rekordy 
  ,null,null
) 
