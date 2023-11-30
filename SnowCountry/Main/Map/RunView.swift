import SwiftUI
	
enum RunState {
    case readyToStart, started, paused, stopped
}

struct RunView: View {
    @State private var currentRunState: RunState = RunState.readyToStart
    @State private var stoppedNotificiation = true
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapboxView() // Hmmmm
            
            switch currentRunState {
            case .readyToStart:
                Button(action: {
                    currentRunState = RunState.started
                    stoppedNotificiation = true
                }) {
                    Image(systemName: "play.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .padding()
                }
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(22)
                .padding()
            case .started:
                HStack {
                    Button(action: {
                        currentRunState = RunState.paused
                    }) {
                        Image(systemName: "pause.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(22)
                    .padding()
                    
                    Button(action: {
                        currentRunState = RunState.stopped
                    }) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(22)
                    .padding()
                }
            case .paused:
                HStack {
                    Button(action: {
                        currentRunState = RunState.started // THINK THIS SHOULD BE RESUMED?
                    }) {
                        Image(systemName: "play.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(22)
                    .padding()
                    
                    Button(action: {
                        currentRunState = RunState.stopped
                    }) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .padding()
                    }
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(22)
                }
            case .stopped:
                VStack {
                    
                }
                .alert(isPresented: $stoppedNotificiation) {
                    Alert(
                        title: Text("Stopped"),
                        message: Text("Stopped run"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        stoppedNotificiation = false
                        currentRunState = RunState.readyToStart
                    }
                }
            }
        }
    }
}
