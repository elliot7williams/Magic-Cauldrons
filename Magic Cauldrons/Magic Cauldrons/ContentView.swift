//
//  ContentView.swift
//  Magic Cauldrons
//
//  Created by Elliot Williams on 2025-06-24.
//

import SwiftUI
import Combine

struct MagicCauldronsGame: View {
    @State private var cauldrons: [Cauldron] = []
    @State private var isInitialized = false
    
    @State private var magicParticles: [MagicParticle] = []
    @State private var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var stirringCauldron: Cauldron? = nil
    
    // Enhanced gameplay features
    @State private var score: Int = 0
    @State private var level: Int = 1
    @State private var experience: Int = 0
    @State private var experienceToNextLevel: Int = 100
    @State private var achievements: Set<Achievement> = []
    @State private var activePowerUps: [PowerUp] = []
    @State private var specialEffects: [SpecialEffect] = []
    @State private var currentRecipe: Recipe? = nil
    @State private var recipeProgress: Int = 0
    @State private var combo: Int = 0
    @State private var comboTimer: Double = 0
    @State private var showLevelUpEffect = false
    @State private var showAchievementNotification: Achievement? = nil
    @State private var totalPotionsBrewed: Int = 0
    @State private var perfectPotions: Int = 0
    @State private var soundEnabled: Bool = true
    @State private var gameMode: GameMode = .freePlay
    
    // New gameplay features
    @State private var timeLeft: Double = 60.0
    @State private var gameOver = false
    @State private var collectedIngredients: [String: Int] = [:]
    @State private var floatingIngredients: [FloatingIngredient] = []
    @State private var shopItems: [ShopItem] = ShopItem.defaultItems
    @State private var showShop = false
    @State private var cauldronUpgrades: [CauldronUpgrade] = CauldronUpgrade.defaultUpgrades
    @State private var activeRecipes: [Recipe] = []
    @State private var difficultyLevel: Double = 1.0
    @State private var streak: Int = 0
    @State private var lastStirTime = Date()
    @State private var ingredientSpawnTimer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var gamePaused = false
    @State private var coins: Int = 100
    @State private var showInstructions = true
    @State private var showTip = true
    
    // Enhanced visual effects
    @State private var screenShakeOffset: CGSize = .zero
    @State private var backgroundPulse: Double = 1.0
    @State private var sparkleParticles: [SparkleParticle] = []
    @State private var stirTrails: [StirTrail] = []
    @State private var potionGlow: [UUID: Double] = [:]
    @State private var ingredientTrails: [IngredientTrail] = []
    @State private var comboFireworks: [FireworkParticle] = []
    
    // New gameplay features
    @State private var weatherEffect: WeatherType = .none
    @State private var weatherTimer: Double = 0
    @State private var mysticalEvents: [MysticalEvent] = []
    @State private var cauldronTemperature: [UUID: Double] = [:]
    @State private var brewingBonus: Double = 1.0
    @State private var magicMeter: Double = 0.0
    @State private var seasonalTheme: SeasonalTheme = .autumn
    @State private var dailyQuests: [DailyQuest] = []
    @State private var completedQuests: Set<UUID> = []
    
    // Sound and haptic feedback
    @State private var lastStirSoundTime: Date = Date()
    @State private var soundCooldown: Double = 0.1

    init() {
        self.timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
        self.ingredientSpawnTimer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
        
        // Initialize magic particles
        var particles: [MagicParticle] = []
        for _ in 0..<50 {
            particles.append(MagicParticle())
        }
        _magicParticles = State(initialValue: particles)
        
        // Generate first recipe if needed
        if gameMode == .recipeChallenge || gameMode == .endless {
            _currentRecipe = State(initialValue: generateRandomRecipe())
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Enhanced Background with seasonal themes and weather effects
                backgroundView(geometry: geometry)
                    .ignoresSafeArea(.all)
                    .scaleEffect(backgroundPulse)
                    .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: backgroundPulse)
                    .offset(screenShakeOffset)
                    .animation(Animation.easeInOut(duration: 0.1), value: screenShakeOffset)
                
                // Enhanced Magic particles with trails and effects
                ForEach(magicParticles) { particle in
                    ZStack {
                        // Particle glow effect
                        Circle()
                            .fill(particle.color.opacity(0.3))
                            .frame(width: particle.size * 3, height: particle.size * 3)
                            .blur(radius: 2)
                        
                        // Main particle
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                    }
                    .position(particle.position)
                    .opacity(particle.opacity)
                }
                
                // Sparkle particles for extra magic
                ForEach(sparkleParticles) { sparkle in
                    SparkleView(sparkle: sparkle)
                        .position(sparkle.position)
                }
                
                // Combo fireworks
                ForEach(comboFireworks) { firework in
                    FireworkView(firework: firework)
                        .position(firework.position)
                }
                
                // Stir trails
                ForEach(stirTrails) { trail in
                    StirTrailView(trail: trail)
                        .position(trail.position)
                }
                
                // Ingredient trails
                ForEach(ingredientTrails) { trail in
                    IngredientTrailView(trail: trail)
                        .position(trail.position)
                }
                
                // Game Over Screen
                if gameOver {
                    GameOverView(score: score, level: level, onRestart: restartGame)
                        .transition(.scale)
                        .zIndex(100)
                }
                
                // Shop View
                if showShop {
                    ShopView(shopItems: $shopItems, coins: $coins, isPresented: $showShop, onPurchase: applyPurchase)
                        .transition(.move(edge: .bottom))
                        .zIndex(50)
                }
                
                // Enhanced HUD at top
                VStack {
                    HStack {
                        // Score and Level Section with animations
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .scaleEffect(score > 0 ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: score)
                                Text("Score: \(score)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.gold)
                                    .rotationEffect(.degrees(level > 1 ? 10 : 0))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: level)
                                Text("Level \(level)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            // Enhanced Experience bar
                            VStack(alignment: .leading, spacing: 2) {
                                Text("XP: \(experience)/\(experienceToNextLevel)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 8)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 120 * (Double(experience) / Double(experienceToNextLevel)), height: 8)
                                        .animation(.easeInOut(duration: 0.5), value: experience)
                                }
                            }
                            
                            // Magic Meter
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Magic: \(Int(magicMeter * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.purple)
                                
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 6)
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: 120 * magicMeter, height: 6)
                                        .animation(.easeInOut(duration: 0.3), value: magicMeter)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Game Title
                        VStack {
                            Text("Magic Cauldrons")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.yellow)
                                .shadow(color: .orange, radius: 2)
                            
                            if let recipe = currentRecipe {
                                Text("Recipe: \(recipe.name)")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                            }
                            
                            if gameMode == .timeAttack && !gameOver {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.orange)
                                    Text("Time: \(Int(timeLeft))")
                                        .font(.headline)
                                        .foregroundColor(timeLeft < 10 ? .red : .white)
                                }
                                .padding(.top, 5)
                            }
                        }
                        
                        Spacer()
                        
                        // Stats Section
                        VStack(alignment: .trailing, spacing: 8) {
                            HStack {
                                Text("Combo: \(combo)x")
                                    .font(.headline)
                                    .foregroundColor(combo > 0 ? .orange : .white)
                                Image(systemName: "flame.fill")
                                    .foregroundColor(combo > 0 ? .orange : .gray)
                            }
                            
                            HStack {
                                Text("Potions: \(totalPotionsBrewed)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "flask.fill")
                                    .foregroundColor(.green)
                            }
                            
                            HStack {
                                Text("Perfect: \(perfectPotions)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.purple)
                            }
                            
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(.yellow)
                                Text("\(coins)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Active Power-ups
                    if !activePowerUps.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(activePowerUps) { powerUp in
                                    PowerUpView(powerUp: powerUp)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 40)
                    }
                    
                    Spacer()
                }
                
                // Enhanced Cauldrons with glow and temperature effects
                ForEach($cauldrons) { $cauldron in
                    ZStack {
                        // Cauldron glow effect based on activity
                        if let glowIntensity = potionGlow[cauldron.id] {
                            Circle()
                                .fill(cauldron.brewColor.opacity(0.3))
                                .frame(width: cauldron.radius * 3, height: cauldron.radius * 3)
                                .blur(radius: 10)
                                .opacity(glowIntensity)
                        }
                        
                        // Temperature effect
                        if let temp = cauldronTemperature[cauldron.id], temp > 0.7 {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: CGFloat(10 + i * 5), height: CGFloat(10 + i * 5))
                                    .offset(y: CGFloat(-30 - i * 10))
                                    .opacity(temp - 0.7)
                            }
                        }
                        
                        CauldronView(cauldron: $cauldron, geometry: geometry, temperature: cauldronTemperature[cauldron.id] ?? 0.0)
                    }
                    .position(cauldron.position)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                handleDrag(value: value, for: cauldron)
                            }
                            .onEnded { _ in
                                stirringCauldron = nil
                            }
                    )
                }
                
                // Floating ingredients
                ForEach(floatingIngredients) { ingredient in
                    IngredientView(ingredient: ingredient)
                        .position(ingredient.position)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if let index = floatingIngredients.firstIndex(where: { $0.id == ingredient.id }) {
                                        floatingIngredients[index].position = value.location
                                    }
                                }
                                .onEnded { value in
                                    checkIngredientDrop(value.location)
                                }
                        )
                }
                
                // Recipe Requirements - positioned at bottom center
                if gameMode == .recipeChallenge && currentRecipe != nil {
                    VStack {
                        Spacer()
                        RecipeRequirementsView(recipe: currentRecipe!, progress: recipeProgress)
                            .padding(12)
                            .background(Color(red: 40/255, green: 20/255, blue: 70/255).opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 120/255, green: 80/255, blue: 180/255), lineWidth: 1.5)
                            )
                            .frame(maxWidth: min(320, geometry.size.width * 0.8))
                            .padding(.bottom, max(30, geometry.safeAreaInsets.bottom + 20))
                    }
                }
                
                // Instructions - positioned to avoid overlapping with cauldrons
                if showInstructions {
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("HOW TO PLAY:")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("(Tap to dismiss)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                                Text("• Tap and drag inside a cauldron to stir")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Text("• Collect floating ingredients")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Text("• Complete recipes for bonus rewards")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                                Text("• Fill the progress bar to complete a potion")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(Color(red: 40/255, green: 20/255, blue: 70/255).opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 120/255, green: 80/255, blue: 180/255), lineWidth: 1.5)
                            )
                            .frame(maxWidth: min(240, geometry.size.width * 0.35))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showInstructions = false
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.bottom, max(160, geometry.size.height * 0.2))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Tip - positioned to avoid overlapping with recipe requirements
                if showTip {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Text("💡 Tip")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.yellow)
                                    Spacer()
                                    Text("(Tap to dismiss)")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                                Text("Stir faster to create more bubbles and brew potions quicker!")
                                    .font(.system(size: 12))
                                    .foregroundColor(.yellow)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(12)
                            .frame(maxWidth: min(240, geometry.size.width * 0.35))
                            .background(Color(red: 40/255, green: 20/255, blue: 70/255).opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showTip = false
                                }
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, max(160, geometry.size.height * 0.2))
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Special Effects Overlay
                ForEach(specialEffects) { effect in
                    SpecialEffectView(effect: effect)
                        .position(effect.position)
                }
                
                // Level Up Effect - positioned to not overlap with other elements
                if showLevelUpEffect {
                    VStack {
                        Text("LEVEL UP!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .orange, radius: 5)
                        
                        Text("Level \(level)")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .position(x: geometry.size.width / 2, y: max(geometry.size.height * 0.4, 300))
                    .scaleEffect(showLevelUpEffect ? 1.5 : 1.0)
                    .animation(.easeInOut(duration: 1.0), value: showLevelUpEffect)
                }
                
                // Achievement Notification - positioned below HUD
                if let achievement = showAchievementNotification {
                    VStack {
                        HStack {
                            Image(systemName: achievement.icon)
                                .font(.title2)
                                .foregroundColor(.yellow)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Achievement Unlocked!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(achievement.title)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(achievement.description)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(12)
                        .background(Color(red: 40/255, green: 20/255, blue: 70/255).opacity(0.95))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                    }
                    .position(x: geometry.size.width / 2, y: max(180, geometry.size.height * 0.2))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Action Buttons - positioned below HUD to avoid overlap
                VStack {
                    HStack {
                        // Shop Button
                        Button(action: { showShop = true }) {
                            Image(systemName: "cart.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.green.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        // Pause Button
                        Button(action: { gamePaused.toggle() }) {
                            Image(systemName: gamePaused ? "play.circle.fill" : "pause.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.purple.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, max(geometry.safeAreaInsets.top + 120, 160)) // Position below HUD
                    
                    Spacer()
                }
            }
            .onReceive(timer) { _ in
                if !gamePaused && !gameOver {
                    updateGame()
                }
            }
            .onReceive(ingredientSpawnTimer) { _ in
                if !gamePaused && !gameOver {
                    spawnIngredientsIfNeeded()
                }
            }
            .onAppear {
                initializeCauldrons(geometry: geometry)
                updateMagicParticlesBounds(geometry: geometry)
            }
        }
    }
    
    private func handleDrag(value: DragGesture.Value, for cauldron: Cauldron) {
        let touchPosition = value.location
        let center = cauldron.position
        
        // Calculate distance from center
        let dx = touchPosition.x - center.x
        let dy = touchPosition.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        
        // Only stir if inside cauldron
        if distance < cauldron.radius {
            // Find the index of the cauldron in the array
            guard let index = cauldrons.firstIndex(where: { $0.id == cauldron.id }) else { return }
            
            // Determine stir direction
            let angle = atan2(dy, dx)
            cauldrons[index].stirDirection = angle > 0 ? 1 : -1
            
            // Calculate stir power
            let power = max(0.1, min(1.0, (cauldron.radius - distance) / cauldron.radius))
            cauldrons[index].stirPower = power
            
            // Add bubbles
            for _ in 0..<Int(power * 5) {
                let randomAngle = Double.random(in: 0..<Double.pi * 2)
                let dist = Double.random(in: 0..<Double(cauldron.radius * 0.7))
                let bx = center.x + CGFloat(dist * cos(randomAngle))
                let by = center.y + CGFloat(dist * sin(randomAngle) * 0.7) + 20
                cauldrons[index].bubbles.append(Bubble(position: CGPoint(x: bx, y: by), cauldronRadius: cauldron.radius))
            }
            
            // Increase creation progress (enhanced with power-ups)
            let stirMultiplier = activePowerUps.contains(where: { $0.type == .fastStir }) ? 1.5 : 1.0
            cauldrons[index].creationProgress += power * 0.8 * stirMultiplier
            
            if cauldrons[index].creationProgress >= cauldrons[index].creationTarget {
                completePotionWithEnhancements(cauldronIndex: index)
                cauldrons[index].creationProgress = 0
                cauldrons[index].generatePotionName()
                cauldrons[index].brewLevel = min(1.0, cauldrons[index].brewLevel + 0.1)
            }
        }
    }
    
    private func initializeCauldrons(geometry: GeometryProxy) {
        // Only initialize if cauldrons array is empty and not already initialized
        if cauldrons.isEmpty && !isInitialized {
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            // Position cauldrons in center with proper spacing
            let cauldronY = max(screenHeight * 0.6, 400)
            let cauldronRadius: CGFloat = 80
            let minSpacing = cauldronRadius * 2.5 // Ensure no overlap
            
            // Calculate total width needed for 3 cauldrons
            let totalWidth = minSpacing * 2
            let availableWidth = screenWidth - 40 // Leave margins
            
            // If screen is too narrow, reduce spacing but maintain minimum distance
            let actualSpacing = min(minSpacing, max(cauldronRadius * 2.2, availableWidth / 2))
            
            // Center the cauldrons
            let centerX = screenWidth / 2
            let startX = centerX - actualSpacing
            
            // Add brew colors back to cauldrons with proper spacing
            cauldrons = [
                Cauldron(position: CGPoint(x: startX, y: cauldronY), brewColor: .green),
                Cauldron(position: CGPoint(x: centerX, y: cauldronY), brewColor: .indigo),
                Cauldron(position: CGPoint(x: startX + actualSpacing * 2, y: cauldronY), brewColor: .gold)
            ]
            isInitialized = true
        }
    }
    
    private func updateMagicParticlesBounds(geometry: GeometryProxy) {
        // Update magic particles to use proper screen bounds
        for index in magicParticles.indices {
            // Clamp particles to screen bounds if they're outside
            if magicParticles[index].position.x < 0 || magicParticles[index].position.x > geometry.size.width {
                magicParticles[index].position.x = CGFloat.random(in: 0..<geometry.size.width)
            }
            if magicParticles[index].position.y < 0 || magicParticles[index].position.y > geometry.size.height {
                magicParticles[index].position.y = CGFloat.random(in: 0..<geometry.size.height)
            }
        }
    }
    
    private func updateGame() {
        // Get screen size from geometry reader context (will be updated)
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Update enhanced gameplay elements
        updatePowerUps()
        updateCombo()
        updateSpecialEffects()
        
        // Update magic particles
        for index in magicParticles.indices {
            // Calculate movement using stored angle
            let dx = cos(magicParticles[index].angle) * 0.5
            let dy = sin(magicParticles[index].angle) * 0.7
            
            // Update positions
            magicParticles[index].position.x += CGFloat(dx)
            magicParticles[index].position.y += CGFloat(dy)
            
            // Wrap around screen
            if magicParticles[index].position.x < 0 {
                magicParticles[index].position.x = screenWidth
            }
            if magicParticles[index].position.x > screenWidth {
                magicParticles[index].position.x = 0
            }
            if magicParticles[index].position.y < 0 {
                magicParticles[index].position.y = screenHeight
            }
            if magicParticles[index].position.y > screenHeight {
                magicParticles[index].position.y = 0
            }
        }
        
        // Update cauldrons
        for index in cauldrons.indices {
            // Reduce stir power
            cauldrons[index].stirPower = max(0, cauldrons[index].stirPower - 0.02)
            
            // Update bubbles
            cauldrons[index].bubbles = cauldrons[index].bubbles.filter { bubble in
                var updatedBubble = bubble
                updatedBubble.age += 1
                updatedBubble.distance += 0.2
                updatedBubble.position.y -= updatedBubble.speed
                return updatedBubble.age < updatedBubble.lifetime && updatedBubble.distance < 70
            }
            
            // Add random bubbles (enhanced with power-ups)
            let bubbleMultiplier = activePowerUps.contains(where: { $0.type == .magicBubbles }) ? 2.0 : 1.0
            if Double.random(in: 0..<1) < 0.3 * bubbleMultiplier {
                let randomAngle = Double.random(in: 0..<Double.pi * 2)
                let dist = Double.random(in: 0..<Double(cauldrons[index].radius * 0.7))
                let bx = cauldrons[index].position.x + CGFloat(dist * cos(randomAngle))
                let by = cauldrons[index].position.y + CGFloat(dist * sin(randomAngle) * 0.7) + 20
                cauldrons[index].bubbles.append(Bubble(position: CGPoint(x: bx, y: by), cauldronRadius: cauldrons[index].radius))
            }
        }
        
        // Update time attack mode
        if gameMode == .timeAttack && !gameOver {
            timeLeft -= 0.05
            if timeLeft <= 0 {
                timeLeft = 0
                gameOver = true
            }
        }
        
        // Update endless mode difficulty
        if gameMode == .endless {
            difficultyLevel += 0.0001
        }
        
        // Update floating ingredients
        updateFloatingIngredients(screenSize: screenSize)
    }
    
    private func updateFloatingIngredients(screenSize: CGSize) {
        let screenHeight = screenSize.height
        
        for index in floatingIngredients.indices {
            // Move ingredient toward its target cauldron
            if let targetId = floatingIngredients[index].targetCauldron,
               let cauldron = cauldrons.first(where: { $0.id == targetId }) {
                
                let dx = cauldron.position.x - floatingIngredients[index].position.x
                let dy = cauldron.position.y - floatingIngredients[index].position.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance > 10 {
                    let speed: CGFloat = 2.0
                    floatingIngredients[index].position.x += dx / distance * speed
                    floatingIngredients[index].position.y += dy / distance * speed
                } else {
                    // Add ingredient to cauldron
                    if let cauldronIndex = cauldrons.firstIndex(where: { $0.id == targetId }) {
                        cauldrons[cauldronIndex].addIngredient(floatingIngredients[index].type)
                        collectedIngredients[floatingIngredients[index].type, default: 0] += 1
                        floatingIngredients.remove(at: index)
                        checkRecipeCompletion()
                        return
                    }
                }
            } else {
                // Fall down if no target
                floatingIngredients[index].position.y += 1.5
            }
            
            // Remove if off screen
            if floatingIngredients[index].position.y > screenHeight + 50 {
                floatingIngredients.remove(at: index)
                return
            }
        }
    }
    
    private func spawnIngredientsIfNeeded() {
        let screenWidth = UIScreen.main.bounds.width
        let spawnChance = gameMode == .endless ? min(0.3 * difficultyLevel, 0.8) : 0.2
        
        if Double.random(in: 0..<1) < spawnChance {
            let ingredientTypes = ["Herb", "Crystal", "Mushroom", "Feather", "Essence"]
            let type = ingredientTypes.randomElement()!
            let position = CGPoint(
                x: CGFloat.random(in: 50..<screenWidth-50),
                y: -30
            )
            
            floatingIngredients.append(FloatingIngredient(
                type: type,
                position: position,
                targetCauldron: cauldrons.randomElement()?.id
            ))
        }
    }
    
    // MARK: - Enhanced Gameplay Functions
    private func updatePowerUps() {
        activePowerUps = activePowerUps.compactMap { powerUp in
            var updatedPowerUp = powerUp
            updatedPowerUp.duration -= 0.05
            return updatedPowerUp.duration > 0 ? updatedPowerUp : nil
        }
    }
    
    private func updateCombo() {
        if comboTimer > 0 {
            comboTimer -= 0.05
        } else if combo > 0 {
            combo = 0
        }
    }
    
    private func updateSpecialEffects() {
        specialEffects = specialEffects.compactMap { effect in
            var updatedEffect = effect
            updatedEffect.duration -= 0.05
            return updatedEffect.duration > 0 ? updatedEffect : nil
        }
    }
    
    private func completePotionWithEnhancements(cauldronIndex: Int) {
        // Base rewards
        var xpGain = 10
        var scoreGain = 50
        
        // Apply power-up multipliers
        if activePowerUps.contains(where: { $0.type == .doubleXP }) {
            xpGain *= 2
        }
        if activePowerUps.contains(where: { $0.type == .scoreMultiplier }) {
            scoreGain = Int(Double(scoreGain) * 1.5)
        }
        
        // Apply combo multiplier
        if combo > 0 {
            scoreGain = Int(Double(scoreGain) * (1.0 + Double(combo) * 0.1))
            xpGain = Int(Double(xpGain) * (1.0 + Double(combo) * 0.1))
        }
        
        // Update stats
        score += scoreGain
        coins += 5
        experience += xpGain
        totalPotionsBrewed += 1
        combo += 1
        comboTimer = 3.0 // 3 seconds to maintain combo
        
        // Check for perfect potion (based on stirring technique)
        if cauldrons[cauldronIndex].stirPower > 0.8 {
            perfectPotions += 1
            score += 25 // Bonus for perfect potion
            coins += 2
            addSpecialEffect(at: cauldrons[cauldronIndex].position, type: .sparkles)
        }
        
        // Check for level up
        if experience >= experienceToNextLevel {
            levelUp()
        }
        
        // Check achievements
        checkAchievements()
        
        // Generate random power-up chance
        if Double.random(in: 0..<1) < 0.1 { // 10% chance
            generateRandomPowerUp()
        }
        
        // Add completion effect
        addSpecialEffect(at: cauldrons[cauldronIndex].position, type: .explosion)
    }
    
    private func levelUp() {
        level += 1
        experience = 0
        experienceToNextLevel = Int(Double(experienceToNextLevel) * 1.2) // Increase requirement
        coins += 10
        showLevelUpEffect = true
        
        // Level up rewards
        generateRandomPowerUp()
        addSpecialEffect(at: CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2), type: .rainbow)
        
        // Hide level up effect after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showLevelUpEffect = false
        }
    }
    
    private func generateRandomPowerUp() {
        let powerUpTypes: [PowerUp.PowerUpType] = [.doubleXP, .fastStir, .magicBubbles, .scoreMultiplier, .timeExtension]
        let randomType = powerUpTypes.randomElement()!
        let duration = Double.random(in: 10.0...20.0)
        let intensity = Double.random(in: 1.0...2.0)
        
        let powerUp = PowerUp(type: randomType, duration: duration, intensity: intensity)
        activePowerUps.append(powerUp)
    }
    
    private func addSpecialEffect(at position: CGPoint, type: SpecialEffect.EffectType) {
        let effect = SpecialEffect(
            position: position,
            type: type,
            duration: 2.0,
            intensity: 1.0
        )
        specialEffects.append(effect)
    }
    
    private func checkAchievements() {
        let potentialAchievements = [
            Achievement(title: "First Brew", description: "Brew your first potion", icon: "flask.fill", requirement: 1, type: .potionsBrewed),
            Achievement(title: "Apprentice Alchemist", description: "Brew 10 potions", icon: "graduationcap.fill", requirement: 10, type: .potionsBrewed),
            Achievement(title: "Master Brewer", description: "Brew 50 potions", icon: "crown.fill", requirement: 50, type: .potionsBrewed),
            Achievement(title: "Perfectionist", description: "Brew 5 perfect potions", icon: "star.fill", requirement: 5, type: .perfectPotions),
            Achievement(title: "Level 5", description: "Reach level 5", icon: "5.circle.fill", requirement: 5, type: .levelReached),
            Achievement(title: "Combo Master", description: "Achieve a 10x combo", icon: "flame.fill", requirement: 10, type: .comboAchieved)
        ]
        
        for achievement in potentialAchievements {
            if !achievements.contains(achievement) {
                var unlocked = false
                switch achievement.type {
                case .potionsBrewed:
                    unlocked = totalPotionsBrewed >= achievement.requirement
                case .perfectPotions:
                    unlocked = perfectPotions >= achievement.requirement
                case .levelReached:
                    unlocked = level >= achievement.requirement
                case .comboAchieved:
                    unlocked = combo >= achievement.requirement
                case .experienceGained:
                    unlocked = experience >= achievement.requirement
                }
                
                if unlocked {
                    achievements.insert(achievement)
                    showAchievementNotification = achievement
                    
                    // Hide notification after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showAchievementNotification = nil
                    }
                }
            }
        }
    }
    
    // MARK: - New Gameplay Functions
    private func spawnIngredientsIfNeeded(geometry: GeometryProxy) {
        let spawnChance = gameMode == .endless ? min(0.3 * difficultyLevel, 0.8) : 0.2
        
        if Double.random(in: 0..<1) < spawnChance {
            let ingredientTypes = ["Herb", "Crystal", "Mushroom", "Feather", "Essence"]
            let type = ingredientTypes.randomElement()!
            let position = CGPoint(
                x: CGFloat.random(in: 50..<geometry.size.width-50),
                y: -30
            )
            
            floatingIngredients.append(FloatingIngredient(
                type: type,
                position: position,
                targetCauldron: cauldrons.randomElement()?.id
            ))
        }
    }
    
    private func updateFloatingIngredients(geometry: GeometryProxy) {
        for index in floatingIngredients.indices {
            // Move ingredient toward its target cauldron
            if let targetId = floatingIngredients[index].targetCauldron,
               let cauldron = cauldrons.first(where: { $0.id == targetId }) {
                
                let dx = cauldron.position.x - floatingIngredients[index].position.x
                let dy = cauldron.position.y - floatingIngredients[index].position.y
                let distance = sqrt(dx*dx + dy*dy)
                
                if distance > 10 {
                    let speed: CGFloat = 2.0
                    floatingIngredients[index].position.x += dx / distance * speed
                    floatingIngredients[index].position.y += dy / distance * speed
                } else {
                    // Add ingredient to cauldron
                    if let cauldronIndex = cauldrons.firstIndex(where: { $0.id == targetId }) {
                        cauldrons[cauldronIndex].addIngredient(floatingIngredients[index].type)
                        collectedIngredients[floatingIngredients[index].type, default: 0] += 1
                        floatingIngredients.remove(at: index)
                        checkRecipeCompletion()
                        return
                    }
                }
            } else {
                // Fall down if no target
                floatingIngredients[index].position.y += 1.5
            }
            
            // Remove if off screen
            if floatingIngredients[index].position.y > geometry.size.height + 50 {
                floatingIngredients.remove(at: index)
                return
            }
        }
    }
    
    private func checkIngredientDrop(_ position: CGPoint) {
        for cauldron in cauldrons {
            let distance = hypot(position.x - cauldron.position.x, position.y - cauldron.position.y)
            if distance < cauldron.radius,
               let ingredientIndex = floatingIngredients.firstIndex(where: { $0.position == position }) {
                
                let ingredientType = floatingIngredients[ingredientIndex].type
                floatingIngredients.remove(at: ingredientIndex)
                
                if let index = cauldrons.firstIndex(where: { $0.id == cauldron.id }) {
                    cauldrons[index].addIngredient(ingredientType)
                    collectedIngredients[ingredientType, default: 0] += 1
                    coins += 1
                    checkRecipeCompletion()
                }
                break
            }
        }
    }
    
    private func checkRecipeCompletion() {
        guard let recipe = currentRecipe else { return }
        
        var hasAllIngredients = true
        for ingredient in recipe.ingredients {
            if collectedIngredients[ingredient, default: 0] < 1 {
                hasAllIngredients = false
                break
            }
        }
        
        if hasAllIngredients {
            // Complete recipe
            recipeProgress += 1
            for ingredient in recipe.ingredients {
                collectedIngredients[ingredient]? -= 1
            }
            
            // Apply recipe rewards
            score += recipe.scoreReward
            experience += recipe.xpReward
            coins += recipe.scoreReward / 10
            
            if recipeProgress >= recipe.stirCount {
                completeRecipe()
            }
        }
    }
    
    private func completeRecipe() {
        guard let recipe = currentRecipe else { return }
        
        // Special effect
        addSpecialEffect(at: CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2),
                         type: .rainbow)
        
        // Apply recipe effect
        switch recipe.difficulty {
        case .easy:
            score += 100
        case .medium:
            activePowerUps.append(PowerUp(type: .doubleXP, duration: 15, intensity: 1.5))
        case .hard:
            timeLeft += 20
        case .expert:
            streak += 1
            score += streak * 50
        }
        
        // Get new recipe
        if gameMode == .recipeChallenge || gameMode == .endless {
            currentRecipe = generateRandomRecipe()
            recipeProgress = 0
        }
    }
    
    private func generateRandomRecipe() -> Recipe {
        let difficulties: [Recipe.Difficulty] = [.easy, .medium, .hard, .expert]
        let names = ["Elixir of Wisdom", "Potion of Strength", "Invisibility Brew", "Love Philter", "Dragon's Breath"]
        let ingredientsList = ["Herb", "Crystal", "Mushroom", "Feather", "Essence"]
        
        return Recipe(
            name: names.randomElement()!,
            ingredients: (1...Int.random(in: 2...4)).map { _ in ingredientsList.randomElement()! },
            stirDirection: [.clockwise, .counterClockwise, .alternating].randomElement()!,
            stirCount: Int.random(in: 3...7),
            difficulty: difficulties.randomElement()!,
            xpReward: Int.random(in: 20...100),
            scoreReward: Int.random(in: 50...300)
        )
    }
    
    private func restartGame() {
        cauldrons = []
        isInitialized = false
        magicParticles = (0..<50).map { _ in MagicParticle() }
        score = 0
        level = 1
        experience = 0
        experienceToNextLevel = 100
        activePowerUps = []
        specialEffects = []
        currentRecipe = nil
        recipeProgress = 0
        combo = 0
        comboTimer = 0
        showLevelUpEffect = false
        showAchievementNotification = nil
        totalPotionsBrewed = 0
        perfectPotions = 0
        gameOver = false
        collectedIngredients = [:]
        floatingIngredients = []
        timeLeft = 60
        streak = 0
        difficultyLevel = 1.0
        gamePaused = false
        coins = 100
        showInstructions = true
        showTip = true
    }
    
    // MARK: - Background and Effects
    private func backgroundView(geometry: GeometryProxy) -> some View {
        let backgroundColor = seasonalTheme.backgroundColor
        
        return ZStack {
            // Seasonal Background
            Rectangle()
                .fill(backgroundColor)

            // Weather Effects
            Group {
                switch weatherEffect {
                case .rain:
                    ForEach(0..<15, id: \.self) { _ in
                        Capsule()
                            .fill(Color.blue.opacity(0.6))
                            .frame(width: 4, height: 12)
                            .position(x: CGFloat.random(in: 0...geometry.size.width), y: CGFloat.random(in: 0...geometry.size.height))
                    }
                case .snow:
                    ForEach(0..<15, id: \.self) { _ in
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 5, height: 5)
                            .position(x: CGFloat.random(in: 0...geometry.size.width), y: CGFloat.random(in: 0...geometry.size.height))
                    }
                case .lightning:
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: CGFloat.random(in: 2...4), height: geometry.size.height)
                            .position(x: CGFloat.random(in: 0...geometry.size.width), y: geometry.size.height / 2)
                    }
                case .mysticalAura:
                    ForEach(0..<6, id: \.self) { _ in
                        Circle()
                            .fill(Color.purple.opacity(0.4))
                            .frame(width: 20, height: 20)
                            .position(x: CGFloat.random(in: 0...geometry.size.width), y: CGFloat.random(in: 0...geometry.size.height))
                    }
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    private func applyPurchase(_ item: ShopItem) {
        coins -= item.cost
        
        switch item.type {
        case .cauldronUpgrade:
            if let upgrade = cauldronUpgrades.first(where: { $0.id == item.id }) {
                for index in cauldrons.indices {
                    // Preserve brew color when applying upgrades
                    let originalColor = cauldrons[index].brewColor
                    cauldrons[index].applyUpgrade(upgrade)
                    cauldrons[index].brewColor = originalColor
                }
            }
        case .permanentBoost:
            switch item.id {
            case "stir_power":
                for index in cauldrons.indices {
                    cauldrons[index].stirMultiplier *= 1.2
                }
            case "xp_boost":
                experienceToNextLevel = Int(Double(experienceToNextLevel) * 0.9)
            case "bubble_boost":
                for index in cauldrons.indices {
                    cauldrons[index].bubbleRate *= 1.5
                }
            default: break
            }
        case .powerUp:
            let powerUp = PowerUp(
                type: PowerUp.PowerUpType.allCases.randomElement()!,
                duration: Double.random(in: 15...30),
                intensity: Double.random(in: 1.5...3.0)
            )
            activePowerUps.append(powerUp)
        }
    }
}

// MARK: - Enhanced Gameplay Models
struct Achievement: Hashable, Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    let type: AchievementType
    
    enum AchievementType {
        case potionsBrewed, perfectPotions, levelReached, comboAchieved, experienceGained
    }
}

struct PowerUp: Identifiable {
    let id = UUID()
    let type: PowerUpType
    var duration: Double
    var intensity: Double
    
    enum PowerUpType: CaseIterable {
        case doubleXP, fastStir, magicBubbles, scoreMultiplier, timeExtension
    }
}

struct SpecialEffect: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: EffectType
    var duration: Double
    var intensity: Double
    
    enum EffectType {
        case explosion, sparkles, lightning, rainbow, stars
    }
}

struct Recipe: Identifiable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let stirDirection: StirDirection
    let stirCount: Int
    let difficulty: Difficulty
    let xpReward: Int
    let scoreReward: Int
    
    enum StirDirection {
        case clockwise, counterClockwise, alternating
    }
    
    enum Difficulty {
        case easy, medium, hard, expert
    }
}

enum GameMode {
    case freePlay, timeAttack, recipeChallenge, endless
}

// MARK: - New Gameplay Models
struct FloatingIngredient: Identifiable {
    let id = UUID()
    let type: String
    var position: CGPoint
    var targetCauldron: UUID?
}

struct ShopItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let cost: Int
    let type: ShopItemType
    
    enum ShopItemType {
        case cauldronUpgrade, permanentBoost, powerUp
    }
    
    static let defaultItems: [ShopItem] = [
        ShopItem(
            id: "stir_power",
            name: "Stir Power+",
            description: "Increase stir effectiveness by 20%",
            icon: "wind",
            cost: 50,
            type: .permanentBoost
        ),
        ShopItem(
            id: "xp_boost",
            name: "XP Boost",
            description: "Reduce XP needed for level up by 10%",
            icon: "bolt.heart.fill",
            cost: 75,
            type: .permanentBoost
        ),
        ShopItem(
            id: "bubble_boost",
            name: "Bubble Boost",
            description: "Increase bubble generation rate",
            icon: "bubbles.and.sparkles",
            cost: 40,
            type: .permanentBoost
        ),
        ShopItem(
            id: "power_up",
            name: "Random Power-up",
            description: "Get a random temporary power-up",
            icon: "sparkles",
            cost: 30,
            type: .powerUp
        )
    ]
}

struct CauldronUpgrade: Identifiable {
    let id: String
    let name: String
    let description: String
    let maxLevel: Int
    
    static let defaultUpgrades: [CauldronUpgrade] = [
        CauldronUpgrade(
            id: "capacity",
            name: "Larger Cauldron",
            description: "Increase potion capacity",
            maxLevel: 3
        ),
        CauldronUpgrade(
            id: "efficiency",
            name: "Brew Efficiency",
            description: "Brew potions faster",
            maxLevel: 5
        ),
        CauldronUpgrade(
            id: "auto_bubble",
            name: "Auto Bubbler",
            description: "Automatically generate bubbles",
            maxLevel: 2
        )
    ]
}

// MARK: - Models
struct Cauldron: Identifiable {
    let id = UUID()
    var position: CGPoint
    var bubbles: [Bubble] = []
    var stirDirection: CGFloat = 0 // -1 for counter-clockwise, 1 for clockwise
    var stirPower: CGFloat = 0
    var brewLevel: CGFloat = 0.5
    var creationProgress: CGFloat = 0
    var creationTarget: CGFloat = 100
    var potionName: String = ""
    let radius: CGFloat = 80
    var stirMultiplier: Double = 1.0
    var bubbleRate: Double = 1.0
    var brewColor: Color
    
    init(position: CGPoint, brewColor: Color) {
        self.position = position
        self.brewColor = brewColor
        self.generatePotionName()
    }
    
    mutating func generatePotionName() {
        let prefixes = ["Mystic", "Enchanted", "Arcane", "Ethereal", "Ancient", "Forbidden"]
        let suffixes = ["Power", "Wisdom", "Invisibility", "Strength", "Speed", "Flight", "Transformation"]
        potionName = "\(prefixes.randomElement() ?? "") \(suffixes.randomElement() ?? "")"
    }
    
    mutating func addIngredient(_ ingredient: String) {
        // Add visual effect
        let angle = Double.random(in: 0..<Double.pi * 2)
        let dist = Double.random(in: 0..<Double(radius * 0.7))
        let bx = position.x + CGFloat(dist * cos(angle))
        let by = position.y + CGFloat(dist * sin(angle) * 0.7) + 20
        
        // Special bubble for ingredient
        bubbles.append(Bubble(
            position: CGPoint(x: bx, y: by),
            cauldronRadius: radius,
            specialIngredient: ingredient
        ))
        
        // Boost progress
        creationProgress += 15
    }
    
    mutating func applyUpgrade(_ upgrade: CauldronUpgrade) {
        switch upgrade.id {
        case "capacity":
            creationTarget *= 0.9 // Easier to complete potions
        case "efficiency":
            stirMultiplier *= 1.2 // More progress per stir
        case "auto_bubble":
            bubbleRate *= 1.5 // More bubbles
        default: break
        }
    }
}

struct Bubble: Identifiable {
    let id = UUID()
    var position: CGPoint
    var radius: CGFloat
    var speed: CGFloat
    var color: Color
    var angle: Double
    var distance: CGFloat
    var lifetime: CGFloat
    var age: CGFloat = 0
    var specialIngredient: String? = nil
    
    init(position: CGPoint, cauldronRadius: CGFloat, specialIngredient: String? = nil) {
        self.position = position
        self.radius = CGFloat.random(in: 2...8)
        self.speed = CGFloat.random(in: 0.5...2.5)
        self.angle = Double.random(in: 0..<Double.pi * 2)
        self.distance = CGFloat.random(in: 0..<cauldronRadius * 0.7)
        self.lifetime = CGFloat.random(in: 50...150)
        self.specialIngredient = specialIngredient
        
        // Bubble color options
        let colors = [
            Color(white: 1.0, opacity: 0.8),
            Color(red: 200/255, green: 230/255, blue: 1.0, opacity: 0.7),
            Color(white: 1.0, opacity: 0.6)
        ]
        
        // Customize for special ingredients
        if let ingredient = specialIngredient {
            switch ingredient {
            case "Crystal":
                color = Color.blue.opacity(0.8)
                radius *= 1.5
            case "Essence":
                color = Color.purple.opacity(0.9)
                speed *= 1.8
            case "Herb":
                color = Color.green.opacity(0.7)
            case "Mushroom":
                color = Color.red.opacity(0.7)
            case "Feather":
                color = Color.white.opacity(0.9)
                speed *= 0.7
            default:
                color = colors.randomElement()!
            }
        } else {
            self.color = colors.randomElement()!
        }
    }
}

struct MagicParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var opacity: Double
    var angle: Double
    
    init() {
        // Use a reasonable default that will be updated by the geometry
        self.position = CGPoint(
            x: CGFloat.random(in: 0..<400),
            y: CGFloat.random(in: 0..<800)
        )
        self.size = CGFloat.random(in: 0.5...3)
        self.opacity = Double.random(in: 0.3...1.0)
        self.angle = Double.random(in: 0..<Double.pi * 2)
        
        // Particle colors
        let colors = [
            Color.green,
            Color.red,
            Color.purple,
            Color.yellow,
            Color.blue,
            Color.pink
        ]
        self.color = colors.randomElement()!
    }
}

// MARK: - Views
struct PowerUpView: View {
    let powerUp: PowerUp
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: iconForPowerUp(powerUp.type))
                .font(.caption)
                .foregroundColor(.white)
            
            Text(nameForPowerUp(powerUp.type))
                .font(.caption2)
                .foregroundColor(.white)
            
            // Duration bar
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(width: 20, height: 3)
                .overlay(
                    Rectangle()
                        .fill(colorForPowerUp(powerUp.type))
                        .frame(width: 20 * (powerUp.duration / 20.0), height: 3)
                        .animation(.linear(duration: 0.1), value: powerUp.duration)
                )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(colorForPowerUp(powerUp.type).opacity(0.3))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(colorForPowerUp(powerUp.type), lineWidth: 1)
        )
    }
    
    private func iconForPowerUp(_ type: PowerUp.PowerUpType) -> String {
        switch type {
        case .doubleXP: return "star.fill"
        case .fastStir: return "speedometer"
        case .magicBubbles: return "bubble.left.and.bubble.right.fill"
        case .scoreMultiplier: return "multiply"
        case .timeExtension: return "clock.fill"
        }
    }
    
    private func nameForPowerUp(_ type: PowerUp.PowerUpType) -> String {
        switch type {
        case .doubleXP: return "2X XP"
        case .fastStir: return "Fast Stir"
        case .magicBubbles: return "Magic Bubbles"
        case .scoreMultiplier: return "Score Boost"
        case .timeExtension: return "Time+"
        }
    }
    
    private func colorForPowerUp(_ type: PowerUp.PowerUpType) -> Color {
        switch type {
        case .doubleXP: return .yellow
        case .fastStir: return .orange
        case .magicBubbles: return .cyan
        case .scoreMultiplier: return .purple
        case .timeExtension: return .green
        }
    }
}

struct SpecialEffectView: View {
    let effect: SpecialEffect
    
    var body: some View {
        Group {
            switch effect.type {
            case .explosion:
                ExplosionEffect(intensity: effect.intensity)
            case .sparkles:
                SparklesEffect(intensity: effect.intensity)
            case .lightning:
                LightningEffect(intensity: effect.intensity)
            case .rainbow:
                RainbowEffect(intensity: effect.intensity)
            case .stars:
                StarsEffect(intensity: effect.intensity)
            }
        }
        .opacity(effect.duration / 2.0) // Fade out over time
    }
}

struct ExplosionEffect: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(Color.orange.opacity(0.8))
                    .frame(width: 10, height: 10)
                    .offset(
                        x: cos(Double(i) * .pi / 4) * 30 * intensity,
                        y: sin(Double(i) * .pi / 4) * 30 * intensity
                    )
            }
        }
    }
}

struct SparklesEffect: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<12, id: \.self) { i in
                Image(systemName: "sparkles")
                    .foregroundColor(.yellow)
                    .font(.caption)
                    .offset(
                        x: cos(Double(i) * .pi / 6) * 20 * intensity,
                        y: sin(Double(i) * .pi / 6) * 20 * intensity
                    )
                    .opacity(0.8)
            }
        }
    }
}

struct LightningEffect: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Image(systemName: "bolt.fill")
                    .foregroundColor(.cyan)
                    .font(.title2)
                    .offset(
                        x: cos(Double(i) * .pi / 2) * 15 * intensity,
                        y: sin(Double(i) * .pi / 2) * 15 * intensity
                    )
            }
        }
    }
}

struct RainbowEffect: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { i in
                let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
                Circle()
                    .stroke(colors[i], lineWidth: 3)
                    .frame(width: CGFloat(20 + i * 10) * intensity, height: CGFloat(20 + i * 10) * intensity)
                    .opacity(0.6)
            }
        }
    }
}

struct StarsEffect: View {
    let intensity: Double
    
    var body: some View {
        ZStack {
            ForEach(0..<10, id: \.self) { i in
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
                    .offset(
                        x: cos(Double(i) * .pi / 5) * 25 * intensity,
                        y: sin(Double(i) * .pi / 5) * 25 * intensity
                    )
            }
        }
    }
}

struct CauldronView: View {
    @Binding var cauldron: Cauldron
    let geometry: GeometryProxy
    let temperature: Double
    
    var body: some View {
        ZStack {
            // Cauldron shadow
            Circle()
                .fill(Color(red: 160/255, green: 100/255, blue: 40/255))
                .frame(width: cauldron.radius * 2, height: cauldron.radius * 2)
                .offset(y: 10)
            
            // Cauldron body
            Circle()
                .fill(Color(red: 205/255, green: 127/255, blue: 50/255))
                .frame(width: cauldron.radius * 2, height: cauldron.radius * 2)
            
            // Cauldron rim
            Circle()
                .stroke(Color(red: 230/255, green: 180/255, blue: 100/255), lineWidth: 5)
                .frame(width: cauldron.radius * 2, height: cauldron.radius * 2)
            
            Circle()
                .fill(Color(red: 205/255, green: 127/255, blue: 50/255))
                .frame(width: (cauldron.radius - 15) * 2, height: (cauldron.radius - 15) * 2)
            
            // Enhanced Brew with temperature effects
            Ellipse()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        cauldron.brewColor,
                        temperature > 0.5 ? cauldron.brewColor.opacity(0.8) : cauldron.brewColor,
                        temperature > 0.8 ? Color.red.opacity(0.3) : cauldron.brewColor.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: cauldron.radius * 2, height: cauldron.radius * 1.4 * cauldron.brewLevel)
                .offset(y: -cauldron.radius * 0.7 * (1 - cauldron.brewLevel) / 2)
                .overlay(
                    // Bubbling surface effect
                    Ellipse()
                        .stroke(cauldron.brewColor.opacity(0.5), lineWidth: 2)
                        .frame(width: cauldron.radius * 2, height: cauldron.radius * 1.4 * cauldron.brewLevel)
                        .offset(y: -cauldron.radius * 0.7 * (1 - cauldron.brewLevel) / 2)
                        .scaleEffect(temperature > 0.3 ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: temperature)
                )
            
            // Bubbles
            ForEach(cauldron.bubbles) { bubble in
                let opacity = 1.0 - Double(bubble.age / bubble.lifetime)
                Circle()
                    .fill(bubble.color)
                    .frame(width: bubble.radius * 2, height: bubble.radius * 2)
                    .position(bubble.position)
                    .opacity(opacity)
            }
            
            // Stir effect
            if cauldron.stirPower > 0 {
                ForEach(0..<8, id: \.self) { i in
                    let angle = Double(Date().timeIntervalSince1970) * 2 * cauldron.stirDirection + Double(i) * .pi / 4
                    let dist = cauldron.radius * 0.7
                    let x = cos(angle) * dist
                    let y = sin(angle) * dist * 0.7
                    
                    Circle()
                        .fill(cauldron.brewColor.opacity(cauldron.stirPower * 0.8))
                        .frame(width: (3 + cauldron.stirPower * 5) * 2, height: (3 + cauldron.stirPower * 5) * 2)
                        .offset(x: x, y: y)
                }
            }
            
            // Progress bar background
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 40/255, green: 20/255, blue: 70/255).opacity(0.8))
                .frame(width: 120, height: 12)
                .offset(y: cauldron.radius + 20)
            
            // Progress bar fill
            RoundedRectangle(cornerRadius: 6)
                .fill(cauldron.brewColor)
                .frame(width: 120 * (cauldron.creationProgress / cauldron.creationTarget), height: 12)
                .offset(x: -60 + (60 * (cauldron.creationProgress / cauldron.creationTarget)), y: cauldron.radius + 20)
            
            // Progress bar border
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(red: 120/255, green: 80/255, blue: 180/255), lineWidth: 2)
                .frame(width: 120, height: 12)
                .offset(y: cauldron.radius + 20)
            
            // Potion name
            Text(cauldron.potionName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(white: 1.0, opacity: 0.9))
                .offset(y: cauldron.radius + 40)
        }
    }
}


// MARK: - New Views
struct GameOverView: View {
    let score: Int
    let level: Int
    let onRestart: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
                
                VStack(spacing: 10) {
                    Text("Final Score: \(score)")
                        .font(.title)
                    Text("Level Reached: \(level)")
                        .font(.title2)
                }
                .foregroundColor(.white)
                
                Button(action: onRestart) {
                    Text("Play Again")
                        .font(.title2)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action: { /* Show leaderboard */ }) {
                    Text("Leaderboard")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(red: 40/255, green: 20/255, blue: 70/255))
            .cornerRadius(20)
            .padding(40)
        }
    }
}

struct RecipeRequirementsView: View {
    let recipe: Recipe
    let progress: Int
    
    // Helper to get stir direction text
    private var stirText: String {
        switch recipe.stirDirection {
        case .clockwise:
            return "Clockwise"
        case .counterClockwise:
            return "Counter-clockwise"
        case .alternating:
            return "Alternating"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recipe: \(recipe.name)")
                .font(.headline)
                .foregroundColor(.yellow)
            
            HStack {
                Text("Progress:")
                ProgressView(value: Double(progress), total: Double(recipe.stirCount))
                    .frame(width: 100)
                Text("\(progress)/\(recipe.stirCount)")
            }
            .foregroundColor(.white)
            
            Text("Ingredients:")
                .font(.subheadline)
                .foregroundColor(.white)
            
            ForEach(recipe.ingredients, id: \.self) { ingredient in
                HStack {
                    Image(systemName: iconForIngredient(ingredient))
                    Text(ingredient)
                }
                .foregroundColor(colorForIngredient(ingredient))
            }
            
            // Use the helper property here
            Text("Stir: \(stirText)")
                .foregroundColor(.cyan)
        }
    }
    
    private func iconForIngredient(_ type: String) -> String {
        switch type {
        case "Herb": return "leaf.fill"
        case "Crystal": return "diamond.fill"
        case "Mushroom": return "circle.fill"
        case "Feather": return "bird.fill"
        case "Essence": return "drop.fill"
        default: return "questionmark"
        }
    }
    
    private func colorForIngredient(_ type: String) -> Color {
        switch type {
        case "Herb": return .green
        case "Crystal": return .blue
        case "Mushroom": return .red
        case "Feather": return .white
        case "Essence": return .purple
        default: return .gray
        }
    }
}

struct IngredientView: View {
    let ingredient: FloatingIngredient
    
    var body: some View {
        Image(systemName: iconForIngredient(ingredient.type))
            .font(.title)
            .foregroundColor(colorForIngredient(ingredient.type))
            .shadow(color: .white, radius: 2)
    }
    
    private func iconForIngredient(_ type: String) -> String {
        switch type {
        case "Herb": return "leaf.fill"
        case "Crystal": return "diamond.fill"
        case "Mushroom": return "circle.fill"
        case "Feather": return "bird.fill"
        case "Essence": return "drop.fill"
        default: return "questionmark"
        }
    }
    
    private func colorForIngredient(_ type: String) -> Color {
        switch type {
        case "Herb": return .green
        case "Crystal": return .blue
        case "Mushroom": return .red
        case "Feather": return .white
        case "Essence": return .purple
        default: return .gray
        }
    }
}

struct ShopView: View {
    @Binding var shopItems: [ShopItem]
    @Binding var coins: Int
    @Binding var isPresented: Bool
    let onPurchase: (ShopItem) -> Void
    
    var body: some View {
        VStack {
            Text("Magic Shop")
                .font(.largeTitle)
                .foregroundColor(.yellow)
                .padding()
            
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("Coins: \(coins)")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 10)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(shopItems) { item in
                        ShopItemView(item: item, coins: coins, onPurchase: onPurchase)
                    }
                }
                .padding()
            }
            
            Button("Close") {
                isPresented = false
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(Color(red: 30/255, green: 15/255, blue: 50/255))
        .cornerRadius(20)
        .padding()
    }
}

struct ShopItemView: View {
    let item: ShopItem
    let coins: Int
    let onPurchase: (ShopItem) -> Void
    
    var canAfford: Bool {
        return coins >= item.cost
    }
    
    var body: some View {
        HStack {
            Image(systemName: item.icon)
                .font(.title)
                .foregroundColor(.yellow)
                .frame(width: 50, height: 50)
                .background(Color.purple.opacity(0.5))
                .cornerRadius(10)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("Cost: \(item.cost) coins")
                    .foregroundColor(canAfford ? .green : .red)
            }
            
            Spacer()
            
            Button(action: {
                if canAfford {
                    onPurchase(item)
                }
            }) {
                Text("Buy")
                    .padding(8)
                    .background(canAfford ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!canAfford)
        }
        .padding()
        .background(Color(red: 50/255, green: 30/255, blue: 70/255))
        .cornerRadius(15)
    }
}

// MARK: - Enhanced Visual Effects Models
struct SparkleParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var life: Double
    var maxLife: Double
    var size: CGFloat
    var rotation: Double
    
    init(position: CGPoint) {
        self.position = position
        self.velocity = CGPoint(
            x: Double.random(in: -50...50),
            y: Double.random(in: -50...50)
        )
        self.life = 1.0
        self.maxLife = Double.random(in: 0.5...2.0)
        self.size = CGFloat.random(in: 3...8)
        self.rotation = Double.random(in: 0...360)
    }
}

struct StirTrail: Identifiable {
    let id = UUID()
    var position: CGPoint
    var life: Double
    var color: Color
    var intensity: Double
    
    init(position: CGPoint, color: Color, intensity: Double) {
        self.position = position
        self.life = 1.0
        self.color = color
        self.intensity = intensity
    }
}

struct IngredientTrail: Identifiable {
    let id = UUID()
    var position: CGPoint
    var life: Double
    var color: Color
    
    init(position: CGPoint, color: Color) {
        self.position = position
        self.life = 1.0
        self.color = color
    }
}

struct FireworkParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var life: Double
    var color: Color
    var size: CGFloat
    
    init(position: CGPoint) {
        self.position = position
        let angle = Double.random(in: 0...2 * .pi)
        let speed = Double.random(in: 50...150)
        self.velocity = CGPoint(
            x: cos(angle) * speed,
            y: sin(angle) * speed
        )
        self.life = 1.0
        self.color = [Color.red, .orange, .yellow, .blue, .purple, .pink].randomElement()!
        self.size = CGFloat.random(in: 4...12)
    }
}

enum WeatherType: CaseIterable {
    case none, rain, snow, lightning, mysticalAura
}

enum SeasonalTheme: CaseIterable {
    case spring, summer, autumn, winter
    
    var backgroundColor: Color {
        switch self {
        case .spring: return Color(red: 120/255, green: 80/255, blue: 120/255)
        case .summer: return Color(red: 40/255, green: 20/255, blue: 80/255)
        case .autumn: return Color(red: 60/255, green: 30/255, blue: 40/255)
        case .winter: return Color(red: 20/255, green: 30/255, blue: 50/255)
        }
    }
}

struct MysticalEvent: Identifiable {
    let id = UUID()
    let type: EventType
    var duration: Double
    var intensity: Double
    
    enum EventType {
        case magicSurge, doubleXP, goldenIngredients, timeWarp
    }
}

struct DailyQuest: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let requirement: Int
    var progress: Int
    let reward: QuestReward
    
    enum QuestReward {
        case coins(Int), xp(Int), powerUp
    }
}

// MARK: - Enhanced Visual Components
struct SparkleView: View {
    let sparkle: SparkleParticle
    
    var body: some View {
        Image(systemName: "sparkles")
            .foregroundColor(.yellow)
            .font(.system(size: sparkle.size))
            .opacity(sparkle.life)
            .rotationEffect(.degrees(sparkle.rotation))
            .scaleEffect(sparkle.life)
    }
}

struct FireworkView: View {
    let firework: FireworkParticle
    
    var body: some View {
        Circle()
            .fill(firework.color)
            .frame(width: firework.size, height: firework.size)
            .opacity(firework.life)
            .scaleEffect(firework.life)
    }
}

struct StirTrailView: View {
    let trail: StirTrail
    
    var body: some View {
        Circle()
            .fill(trail.color.opacity(trail.life * trail.intensity))
            .frame(width: 8, height: 8)
            .blur(radius: 2)
    }
}

struct IngredientTrailView: View {
    let trail: IngredientTrail
    
    var body: some View {
        Circle()
            .fill(trail.color.opacity(trail.life * 0.5))
            .frame(width: 4, height: 4)
            .blur(radius: 1)
    }
}

// MARK: - Extensions
extension Color {
    static let indigo = Color(red: 75/255, green: 0/255, blue: 130/255)
    static let gold = Color(red: 255/255, green: 215/255, blue: 0/255)
}

// MARK: - ContentView Wrapper
struct ContentView: View {
    var body: some View {
        MagicCauldronsGame()
    }
}

// MARK: - Preview
struct MagicCauldronsGame_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (11-inch) (4th generation)")
    }
}
