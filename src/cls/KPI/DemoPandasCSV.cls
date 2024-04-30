Class KPI.DemoPandasCSV Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<!-- 'manual' KPI type will tell DeepSee that data will be gathered from the class method defined by us-->
 
<kpi name="MembersPandasDemoCSV" sourceType="manual">
 
 <!-- we are going to need only one column for our KPI query -->
 
<property columnNo="1" name="Male" displayName="Male"/>
<property columnNo="2" name="Female" displayName="Female"/>

 
 </kpi>
}

ClassMethod MembersDF() As %Library.DynamicArray [ Language = python ]
{

    import iris
    
    import pandas as pd

    try:
        data = pd.read_csv("/usr/irissys/csp/src/FakeData.csv")
    except FileNotFoundError:
        data = pd.read_csv(r"/opt/analytics/FakeData.csv")

    grouped_data = data.groupby(["gender"]).count()

    gender_count = grouped_data["id"]

    female_count = gender_count.iloc[0]
    male_count = gender_count.iloc[1]
    
    OBJIDList = iris.cls('%Library.DynamicArray')._New()
    OBJtimeList = iris.cls('%Library.DynamicArray')._New()
 
    
   
    return int(female_count), int(male_count)
}

Method %OnLoadKPI() As %Status
{

	set sqlValue = ..MembersDF()
 
	set female = sqlValue.GetAt(1)
	set male = sqlValue.GetAt(2)

	set rowCount = 1
 
	set colCount = 1
    
	for rows = 1:1:rowCount
	{
        set ..%seriesNames(rows)="Population"
   	
        for col = 1:1:colCount
        {
            set ..%data(rows,"Male")=male
            set ..%data(rows, "Female")=female
        }
	}
	quit $$$OK
}

}
