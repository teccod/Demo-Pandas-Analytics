Class KPI.DemoPandas Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<!-- 'manual' KPI type will tell DeepSee that data will be gathered from the class method defined by us-->
 
<kpi name="MembersPandasDemo" sourceType="manual">
 
 <!-- we are going to need only one column for our KPI query -->
 
<property columnNo="1" name="Members" displayName="Community Members"/>
 
<!-- and lastly we should define a filter for our members -->
 
<filter name="Lang"
displayName="Language"
sql="SELECT DISTINCT Lang from Community.Member"/>
 
 </kpi>
}

ClassMethod MembersDF(sqlstring) As %Library.DynamicArray [ Language = python ]
{


    import iris
    
    import pandas as pd
    
    Id_list = []
    time_list = []
 
    query = """

    SELECT
    id as ID, CAST(TO_CHAR(Created, 'YYYYMM') as Int) as MonthYear, Lang as Lang
    FROM Community.Member
    order by Created ASC

    """
    
    sql_class = iris.sql.prepare(query)
 
    rs = sql_class.execute()
 
    data = rs.dataframe()
    
    if sqlstring:
        data = data.loc[data["lang"] == sqlstring]
 

    grouped_data = data.groupby(["monthyear"]).count()
    

    sorted_filtered_dates = [item for item in set(data["monthyear"])]

    
    date = sorted(sorted_filtered_dates, reverse=True)
   
    
    id = grouped_data["id"].tolist()
    
    
    OBJIDList = iris.cls('%Library.DynamicArray')._New()
    OBJtimeList = iris.cls('%Library.DynamicArray')._New()
 
    
    for i in date:
        OBJtimeList._Push(i)
    for i in id:
        OBJIDList._Push(i)
    return OBJIDList, OBJtimeList
}

Method %OnLoadKPI() As %Status
{
 
 
 set sqlstring = 0
    
	if $IsObject(..%filterValues) {
        if (..%filterValues.InterSystemsMember'="")
        {
            set sqlstring=..%filterValues.%data("Language")
        }
	}
	
	set sqlValue = ..MembersDF(sqlstring)
 
	
	set idList = sqlValue.GetAt(1)
	set timeList = sqlValue.GetAt(2)
   
	
	set rowCount = timeList.%Size()
 
	
	set colCount = 1
	set ..%seriesCount=rowCount
  
    
	for rows = 1:1:..%seriesCount
	{
        set ..%seriesNames(rows)=timeList.%Get(rows-1)
   	
        for col = 1:1:colCount
        {
            set ..%data(rows,"Members")=idList.%Get(rows-1)
        }
	}
	quit $$$OK
}

}
