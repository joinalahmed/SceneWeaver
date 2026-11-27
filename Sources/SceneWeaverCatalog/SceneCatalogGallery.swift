import SwiftUI
import SceneWeaver

/// A searchable native browser backed by the same inventory as Studio.
public struct SceneCatalogGallery: View {
    @State private var search = ""
    @State private var category = "All categories"
    @State private var selected = "component-sky"
    @State private var componentMode = true
    @State private var hour = 18.6
    @State private var weather = SceneWeather.clear
    public init() {}
    private var entries:[SceneCatalog.Item] { componentMode ? SceneCatalog.components : SceneCatalog.scenes }
    private var categories: [String] { ["All categories"] + Set(entries.map(\.category)).sorted() }
    private var filtered: [SceneCatalog.Item] { entries.filter {
        (category == "All categories" || $0.category == category) &&
        (search.isEmpty || ([$0.name,$0.id]+$0.tags).joined(separator:" ").localizedCaseInsensitiveContains(search))
    } }
    public var body: some View {
        VStack(spacing:16) {
            Picker("Collection",selection:$componentMode) {
                Text("Components").tag(true)
                Text("All scenes").tag(false)
            }.pickerStyle(.segmented).onChange(of:componentMode) { _, _ in
                category="All categories";search="";selected=entries.first?.id ?? "component-sky"
            }
            if let scene=SceneCatalog.scene(id:selected) {
                let start=Calendar.current.startOfDay(for:.now)
                SceneView(schedule:DaylightSchedule(orderedDates:[5,6,12,15,18,19.5].map{start.addingTimeInterval($0*3600)}),now:start.addingTimeInterval(hour*3600),weather:weather,scene:scene.definition,ground:36)
                    .frame(height:280).clipped().accessibilityLabel(scene.name)
                Text(scene.name).font(.headline)
            }
            Slider(value:$hour,in:0...23.99).accessibilityLabel("Time of day")
            HStack {
                TextField("Search scenes",text:$search)
                Picker("Category",selection:$category) { ForEach(categories,id:\.self){Text($0)} }
            }
            Text("\(filtered.count) of \(entries.count) \(componentMode ? "components" : "scenes")").font(.caption).foregroundStyle(.secondary)
            ScrollView { LazyVStack(alignment:.leading,spacing:4) { ForEach(filtered){scene in
                Button { selected=scene.id } label: { HStack { Text(scene.name);Spacer();Text(scene.category).font(.caption).foregroundStyle(.secondary) }.padding(8) }.buttonStyle(.plain)
            } } }
        }.padding()
    }
}

/// A single optional catalog scene, ready to embed in a SwiftUI card or header.
public struct SceneCatalogView:View {
    private let id:String;private let hour:Double;private let weather:SceneWeather;private let paused:Bool
    public init(id:String,hour:Double=18.6,weather:SceneWeather = .clear,paused:Bool=false){self.id=id;self.hour=hour;self.weather=weather;self.paused=paused}
    public var body:some View {
        if let item=SceneCatalog.scene(id:id){
            let start=Calendar.current.startOfDay(for:.now)
            SceneView(schedule:DaylightSchedule(orderedDates:[5,6,12,15,18,19.5].map{start.addingTimeInterval($0*3600)}),now:start.addingTimeInterval(hour*3600),weather:weather,scene:item.definition,ground:36,paused:paused)
        }
    }
}
