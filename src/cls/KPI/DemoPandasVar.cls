Class KPI.DemoPandasVar Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="MembersPandasDemoVar" sourceType="manual">
 
<property columnNo="1" name="Members" displayName="Community Members"/>
 
 
 </kpi>
}

ClassMethod MembersDF() As %Library.DynamicArray [ Language = python ]
{


    import iris

    import pandas as pd
    import numpy as np
    
    from scipy.stats import norm

    Id_list = []
   
    query = """

    SELECT
    count(id) as ID
    FROM Community.Member
    group by CAST(TO_CHAR(Created, 'YYYYMM') as Int)
    order by Created ASC

    """
    
    sql_class = iris.sql.prepare(query)
 
    rs = sql_class.execute()
 
    data = rs.dataframe()

    id_count = data["id"].to_list()
    mean = np.mean(id_count)
    std_dev = np.std(id_count)

    x = np.linspace(mean - 3*std_dev, mean + 3*std_dev, 100)

    y = norm.pdf(x, mean, std_dev)

    OBJXList = iris.cls('%Library.DynamicArray')._New()
    OBJYList = iris.cls('%Library.DynamicArray')._New()
   
    
    for i in list(x):
        OBJXList._Push(int(i))
    for i in list(y):
        OBJYList._Push("{:.5f}".format(float(i)))
    return OBJXList, OBJYList
}

Method %OnLoadKPI() As %Status
{
 
	set sqlValue = ..MembersDF()
 
	set x = sqlValue.GetAt(1)
	set y = sqlValue.GetAt(2)
    
	set rowCount = x.%Size()
 
	set colCount = 1
	set ..%seriesCount=rowCount
  
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
