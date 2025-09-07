```plantuml
@startuml C4_Elements

!include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml

' !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

' !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Component.puml



Person(personAlias, "Label", "Optional Description")

Container(containerAlias, "Label", "Technology", "Optional Description")

System(systemAlias, "Label", "Optional Description")



Rel(personAlias, containerAlias, "Label", "Optional Technology")

@enduml
```

