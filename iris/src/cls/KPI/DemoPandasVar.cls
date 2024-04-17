Class KPI.DemoPandasVar Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<!-- 'manual' KPI type will tell DeepSee that data will be gathered from the class method defined by us-->
 
<kpi name="MembersPandasDemoVar" sourceType="manual">
 
 <!-- we are going to need only one column for our KPI query -->
 
<property columnNo="1" name="Members" displayName="Community Members"/>
 
<!-- and lastly we should define a filter for our members -->
 
 </kpi>
}

ClassMethod MembersDF() As %Library.DynamicArray [ Language = python ]
{

    # First of all, we import the most important library in our script: IRIS.
    # IRIS library provides syntax for calling ObjectScript classes.
    # It simplifies Python-ObjectScript integration.
    # With the help of the library we can call any class and class method, and
    # it returns whatever data type we like, and ObjectScript understands it.

    import iris

    # Then, of course, import the pandas itself.

    import pandas as pd
    import numpy as np
    
    from scipy.stats import norm

    # Create three empty arrays:
    Id_list = []
   
    # Next step: define a query against the database:
    
    # Define SQL query for fetching data.
    # The query can be as simple as possible.
    # All the work will be done by pandas:
    query = """

    SELECT
    count(id) as ID
    FROM Community.Member
    group by CAST(TO_CHAR(Created, 'YYYYMM') as Int)
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

    id_count = data["id"].to_list()
    mean = np.mean(id_count)
    std_dev = np.std(id_count)

    x = np.linspace(mean - 3*std_dev, mean + 3*std_dev, 100)

    y = norm.pdf(x, mean, std_dev)

   
    # Now, we should group the data and define x-axis for it:
 
    # Group data by date displayed like MonthYear:
    
 
    # In order to return the appropriate object to ObjectScript so that it understands it,
    # we call '%Library.DynamicArray' (it is the closest one to python and an easy-to-use type of array).
    # Again, we use IRIS library inside python code:
    OBJXList = iris.cls('%Library.DynamicArray')._New()
    OBJYList = iris.cls('%Library.DynamicArray')._New()
   
 
    # Append all data to DynamicArray class methods Push()
    
    for i in list(x):
        OBJXList._Push(int(i))
    for i in list(y):
        OBJYList._Push("{:.5f}".format(float(i)))
    return OBJXList, OBJYList
}

Method %OnLoadKPI() As %Status
{
 
 
	//Call pandas function, pass filter value if any, and receive dynamic arrays with data.
	set sqlValue = ..MembersDF()
 
	//Assign each tuple to a variable.
	set x = sqlValue.GetAt(1)
	set y = sqlValue.GetAt(2)
    
	//Calculate size of x-axis. It will be rows for our widget:
	set rowCount = x.%Size()
 
	//Since we need only one column, we assign variable to 1:
	set colCount = 1
	set ..%seriesCount=rowCount
  
    //Now, for each row, assign time value and ID value of our members:
	for rows = 1:1:..%seriesCount
	{
        set ..%seriesNames(rows)=x.%Get(rows-1)
   	
        for col = 1:1:colCount
        {
            set ..%data(rows,"Members")=y.%Get(rows-1)
        }
	}
	quit $$$OK
}

}
