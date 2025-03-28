PImage buffer;
PImage original;
float[] displacementField;
float[] velocityField;
float crunchFactor = 0.001;  
float turbulence = 0.002; 
float persistence = 0.001; 
int blockSize = 4; 
float influenceRadius = 10; 

void setupCrunchyEffect() {
	buffer = createImage(width, height, RGB);
	original = createImage(width, height, RGB);
	
	int fieldSize = (width/blockSize) * (height/blockSize);
	displacementField = new float[fieldSize * 2]; 
	velocityField = new float[fieldSize * 2]; 
	
	for (int i = 0; i < fieldSize * 2; i++) {
		displacementField[i] = 0;
		velocityField[i] = 0;
	}
	
	original.copy(get(), 0, 0, width, height, 0, 0, width, height);
}

void updateCrunchyEffect() {
	if (!usePixelEffect) return;
	
	buffer.copy(get(), 0, 0, width, height, 0, 0, width, height);
	buffer.loadPixels();
	original.loadPixels();
	
	float mouseStrength = 20;  
	
	for (int x = 0; x < width; x += blockSize) {
		for (int y = 0; y < height; y += blockSize) {
		int fieldIndex = ((x/blockSize) + (y/blockSize) * (width/blockSize)) * 2;
		
		boolean withinInfluence = false;
		
		float maxPower = 0;
		float netVelX = 0;
		float netVelY = 0;
		
		for (int i = 0; i < blobs.size(); i++) {
			if(blobs.get(i).lifeSpan <= 0) continue;
			float dx = x - blobs.get(i).position.x;
			float dy = y - blobs.get(i).position.y;
			float dist = sqrt(dx*dx + dy*dy);
			
			if (dist < blobs.get(i).size) {
				withinInfluence = true;
				float power = pow(1 - dist/blobs.get(i).size, 2) * mouseStrength;
				maxPower = max(maxPower, power);
				
				float angle = noise(x * 0.01, y * 0.01, frameCount * 0.01 + i) * TWO_PI;
				
				netVelX += cos(angle) * power + blobs.get(i).velocity.x;
				netVelY += sin(angle) * power + blobs.get(i).velocity.y;
			}
		}
		
		if (withinInfluence) {
			velocityField[fieldIndex] += netVelX;
			velocityField[fieldIndex+1] += netVelY;
			
			if (random(1) < 0.05) {
				velocityField[fieldIndex] = random(-crunchFactor, crunchFactor);
				velocityField[fieldIndex+1] = random(-crunchFactor, crunchFactor);
			}
		} else {
			velocityField[fieldIndex] *= 1.001;
			velocityField[fieldIndex+1] *= 1.001;
			displacementField[fieldIndex] *= 1.001;
			displacementField[fieldIndex+1] *= 1.001;
		}
		
		displacementField[fieldIndex] += velocityField[fieldIndex];
		displacementField[fieldIndex+1] += velocityField[fieldIndex+1];
		
		if (withinInfluence) {
			velocityField[fieldIndex] *= persistence;
			velocityField[fieldIndex+1] *= persistence;
			displacementField[fieldIndex] *= persistence;
			displacementField[fieldIndex+1] *= persistence;
		}
		
		float displaceX = displacementField[fieldIndex];
		float displaceY = displacementField[fieldIndex+1];
		
		if (!withinInfluence && abs(displaceX) < 0.1 && abs(displaceY) < 0.1) {
			continue;
		}
		
		int sourceX = constrain(int(x + displaceX), 0, width-blockSize);
		int sourceY = constrain(int(y + displaceY), 0, height-blockSize);
		
		for (int bx = 0; bx < blockSize; bx++) {
			for (int by = 0; by < blockSize; by++) {
				if (x+bx < width && y+by < height) {
					int targetLoc = (x+bx) + (y+by) * width;
					int sourceLoc = (sourceX+bx) + (sourceY+by) * width;
					
					if (sourceLoc >= 0 && sourceLoc < buffer.pixels.length) {
						color c = buffer.pixels[sourceLoc];
						
						if (withinInfluence && random(1) < 0.01) { // Occasional color glitches
							int r = (int)red(c) ^ (int)random(50);
							int g = (int)green(c) ^ (int)random(50);
							int b = (int)blue(c) ^ (int)random(50);
							c = color(r, g, b);
						}
					
						buffer.pixels[targetLoc] = c;
					}
				}
			}
		}
		}
	}
	
	// Update and display
	buffer.updatePixels();
	image(buffer, 0, 0);
  
	// if (frameCount % 2 == 0) {  // Every other frame
	// 	// Add noise pixels around blobs
	// 	loadPixels();
	// 	for (int i = 0; i < blobs.size(); i++) {
	// 		if (blobs.get(i).lifeSpan <= 0) continue;
			
	// 		float noiseRadius = blobs.get(i).size * 1.5;
	// 		int noiseCount = (int)(blobs.get(i).size * 0.25); // Reduced from 0.5 to 0.25
			
	// 		for (int j = 0; j < noiseCount; j++) {
	// 			float angle = random(TWO_PI);
	// 			float distance = random(blobs.get(i).size * 0.7, noiseRadius);
				
	// 			int nx = constrain((int)(blobs.get(i).position.x + cos(angle) * distance), 0, width-1);
	// 			int ny = constrain((int)(blobs.get(i).position.y + sin(angle) * distance), 0, height-1);
				
	// 			if (random(1) < 0.6) { // Reduced from 0.8 to 0.6
	// 				int greyValue = (int)random(20, 120);
					
	// 				// Calculate opacity based on distance
	// 				float normalizedDistance = (distance - blobs.get(i).size * 0.7) / (noiseRadius - blobs.get(i).size * 0.7);
	// 				int alpha = (int)(255 * (1.0 - normalizedDistance));
					
	// 				// Get the current pixel color and blend with the noise
	// 				color currentColor = pixels[nx + ny * width];
	// 				color noiseColor = color(greyValue, alpha);
	// 				pixels[nx + ny * width] = blendColor(currentColor, noiseColor, BLEND);
	// 			}
	// 		}
	// 	}
	// 	updatePixels();
	// }

	
	if (frameCount % 2 == 0) {  // Every other frame
		stroke(0, 1);  // Very light opacity for subtle effect
		for (int y = 0; y < height; y += 1) {  // Every pixel row for fine dithering
			boolean drawLine = false;
			float lineStartX = width;
			float lineEndX = 0;
			
			for (int i = 0; i < blobs.size(); i++) {
				if(blobs.get(i).lifeSpan <= 0) continue;
				float scanlineRadius = blobs.get(i).size * 1.2;
				if (abs(y - blobs.get(i).position.y) < scanlineRadius) {
					drawLine = true;
					lineStartX = min(lineStartX, max(0, blobs.get(i).position.x - scanlineRadius));
					lineEndX = max(lineEndX, min(width, blobs.get(i).position.x + scanlineRadius));
				}
			}
			
			if (drawLine) {
				line(lineStartX, y, lineEndX, y);
			}
		}
	}
}

// Toggle the effect with 'c' key and adjust parameters with number keys
void toggleCrunchyEffect() {
  if (key == 'c') {
    usePixelEffect = !usePixelEffect;
    if (usePixelEffect) {
      setupCrunchyEffect();
    }
  }
  
  // Adjust parameters with number keys
  if (key >= '1' && key <= '9') {
    int num = key - '0';
    crunchFactor = num * 2.0;
  }
}
