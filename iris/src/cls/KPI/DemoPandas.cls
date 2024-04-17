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

    # First of all, we import the most important library in our script: IRIS.
    # IRIS library provides syntax for calling ObjectScript classes.
    # It simplifies Python-ObjectScript integration.
    # With the help of the library we can call any class and class method, and
    # it returns whatever data type we like, and ObjectScript understands it.

    import iris
    # Then, of course, import the pandas itself.
    import pandas as pd
    # Create three empty arrays:
    Id_list = []
    time_list = []
 
    # Next step: define a query against the database:
    
    # Define SQL query for fetching data.
    # The query can be as simple as possible.
    # All the work will be done by pandas:
    query = """

    SELECT
    id as ID, CAST(TO_CHAR(Created, 'YYYYMM') as Int) as MonthYear, Lang as Lang
    FROM Community.Member
    order by Created ASC

    """
    # Then, we need to save the resulting data into an array group:

    # Call the class specified for executing SQL statements.
    # We use embedded Python library to call the class:
    sql_class = iris.sql.prepare(query)
 
    # We use it again to call dedicated class methods:
    rs = sql_class.execute()
 
    # Then we use pandas directly on the result set to make dataFrame:
    data = rs.dataframe()
    
    # We also can pass an argument to filter our data frame.
    # Filter example
    # We take an argument sqlstring which, in this case, contains boolean data.
    # With a handy function .loc filtering all the data
    if sqlstring:
        data = data.loc[data["lang"] == sqlstring]
 
    # Now, we should group the data and define x-axis for it:
 
    # Group data by date displayed like MonthYear:
    grouped_data = data.groupby(["monthyear"]).count()
    
    """
    Unfortunately, we cannot take the date column directly from grouped data DataFrame,
    so, instead, we take the date column from the original DataFrame and process it.
    """
 
    # Filter out duplicate dates and append them to a list.
    # After grouping by MonthYear, pandas automatically filters off duplicate dates.
    # We should do the same to match our arrays:
    sorted_filtered_dates = [item for item in set(data["monthyear"])]

    # Reverse the dates from left to right:
    date = sorted(sorted_filtered_dates, reverse=True)
   
    # Convert dict to a list:
    id = grouped_data["id"].tolist()
    
    
    # Reverse values according to the date array:
    
   
    # In order to return the appropriate object to ObjectScript so that it understands it,
    # we call '%Library.DynamicArray' (it is the closest one to python and an easy-to-use type of array).
    # Again, we use IRIS library inside python code:
    OBJIDList = iris.cls('%Library.DynamicArray')._New()
    OBJtimeList = iris.cls('%Library.DynamicArray')._New()
 
    # Append all data to DynamicArray class methods Push()
    for i in date:
        OBJtimeList._Push(i)
    for i in id:
        OBJIDList._Push(i)
    return OBJIDList, OBJtimeList
}

Method %OnLoadKPI() As %Status
{
 
 //Define string for the filter. Set the default to zero
 set sqlstring = 0
    //Call %filterValues method to fetch any filter data from the widget.
	if $IsObject(..%filterValues) {
        if (..%filterValues.InterSystemsMember'="")
        {
            set sqlstring=..%filterValues.%data("Language")
        }
	}
	//Call pandas function, pass filter value if any, and receive dynamic arrays with data.
	set sqlValue = ..MembersDF(sqlstring)
 
	//Assign each tuple to a variable.
	set idList = sqlValue.GetAt(1)
	set timeList = sqlValue.GetAt(2)
   
	//Calculate size of x-axis. It will be rows for our widget:
	set rowCount = timeList.%Size()
 
	//Since we need only one column, we assign variable to 1:
	set colCount = 1
	set ..%seriesCount=rowCount
  
    //Now, for each row, assign time value and ID value of our members:
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
