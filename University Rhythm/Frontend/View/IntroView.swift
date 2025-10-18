import SwiftUI


struct IntroView: View {
    
    var body: some View {
          NavigationStack {
              ZStack {
                  // Background image
                  Image("astronaut")
                      .resizable()
                      .scaledToFill()
                      .ignoresSafeArea() // makes it cover the whole screen
                  
                  // Foreground content
                  VStack(spacing: 30) {
                      Spacer().frame(height: 100)
                      
                      Text("Welcome to Y Rhythm!")
                          .font(.largeTitle)
                          .fontWeight(.bold)
                          .multilineTextAlignment(.center)
                          .foregroundColor(.black)
                          .shadow(radius: 5)
                      
                      
                      Text("This app is designed to help you get into your rhythm at BYU—learn to speak the language of BYU, and how to make the most of your BYU experience!")
                          .font(.title3)
                          .multilineTextAlignment(.center)
                          .foregroundColor(.black)
                          .shadow(radius: 5)
                          .padding(.horizontal)
                          .padding(.horizontal)
                      
                      Spacer()
                      
                      // Navigation button to SSMView
                      NavigationLink(destination: ssmView()) {
                          HStack {
                              Text("Get Started")
                                  .font(.title2)
                                  .fontWeight(.semibold)
                              Image(systemName: "chevron.right")
                                  .font(.title2)
                          }
                          .padding()
                          .foregroundColor(.white)
                          .background(Color.orange.opacity(0.8))
                          .cornerRadius(12)
                          .shadow(radius: 5)
                      }
                      .padding()
                  }
                  .frame(maxHeight: .infinity)
              }
          }
      }
  }


struct ssmView: View{
    @State private var isSpinning = false
    
    var body: some View {
        NavigationStack {
            ScrollView { // allows text to scroll on small devices
                VStack(spacing: 30) {
                    
                    // Text at top
                    Text("""
                    Introducing the Student Success Model

                    A model developed by the Office of 
                    First-Year Experience 
                    that defines the areas that have
                    the most impact on a student's success.
                    """)
                        .font(.title3)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Spinning image
                    Image("Image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600, height: 600)
                        .rotationEffect(Angle.degrees(isSpinning ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 1),
                            value: isSpinning
                        )
                        .onAppear {
                            isSpinning = true
                        }
                    
                    
                    
                    // Navigation button
                    NavigationLink(destination: ssmNextView()) {
                        HStack {
                            Text("Next")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                                .font(.title2)
                        }
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct ssmNextView: View {
    @State private var imageOffset: CGFloat = 300 // start offscreen
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20) {
                // Image that slides up
                Image("Image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 450, height: 450)
                    .offset(y: imageOffset)
                    .animation(.easeOut(duration: 1), value: imageOffset)
                    .onAppear {
                        imageOffset = 0 // slide up when view appears
                    }
                
                Text("This may look like a lot, but don’t worry! We will help you get started and guide you through everything step by step.")
                    .font(.title3)
                
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 30)
                
                NavigationLink(destination: ContentView()) {
                    HStack {
                        Text("Next")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    
                    
                }
                .padding()
            }}
        }
    }
    

#Preview {
    IntroView()
}

