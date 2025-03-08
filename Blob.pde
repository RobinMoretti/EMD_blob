class Blob{
	PVector position, velocity, acceleration;
	int id;
	ArrayList<BodyPart> bodyParts = new ArrayList<BodyPart>();

	float maxSpeed = 1;
	float maxForce = 0.1;
	float minDistance = 25;
	float perceptionRadius = 50;

	float maxLifeSpan = 1000;
	float lifeSpan;

	int nextChildSpawnCount = 4;

	float maxSize = 20;
	float minSize = 2;
	float size = 10;

	Blob(PVector _position, PVector _velocity, BodyPart _parentBodyPart){
		size = random(minSize, maxSize);

		id = blobs.size();
		position = _position;
		velocity = _velocity;

		acceleration = new PVector();

		lifeSpan = random(0, maxLifeSpan);

		if(_parentBodyPart != null){
			bodyParts.add(new BodyPart(_parentBodyPart.position.copy(), random(5, 10)));
		}
		else{
			PVector bodyPartPosition = new PVector();
			bodyPartPosition.x = position.x + random(-10, 10);
			bodyPartPosition.y = position.y + random(-10, 10);
			bodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));
		}
	} 

	void update(){
		// change slowly the size of the blob with randomness
		size += random(-1, 1);
		size = constrain(size, minSize, maxSize);

		repulsion();
		
		// Add some randomness to the velocity
		PVector randomForce = PVector.random2D();
		randomForce.mult(0.15); 
		velocity.add(randomForce);
		
		if(lifeSpan > 0){
			position.add(velocity);
			lifeSpan--;
		}
		else{
			// stop the blob
			velocity.mult(0);
		}

		for (BodyPart bodyPart : bodyParts) {
			// bodyPart.draw();
		}

		
		BodyPart lastBodyPart = bodyParts.get(bodyParts.size() - 1);
		float distance = PVector.dist(position, lastBodyPart.position);
		
		if(distance > minDistance){
			if(bodyParts.size() % nextChildSpawnCount == 0){
				nextChildSpawnCount = (int)random(4, 9);

				// check first if the blob have a minum distance with other blobs
				boolean canSpawn = true;
				for (Blob blob : blobs) {
					if(blob != this){
						float distanceWithOtherBlob = PVector.dist(position, blob.position);
						if(distanceWithOtherBlob < minDistance * 3){
							canSpawn = false;
							break;
						}
					}
				}

				if(!canSpawn){
					return;
				}

				// First, calculate a perpendicular direction to velocity
				PVector perpDirection = new PVector(velocity.y, -velocity.x);
				perpDirection.normalize();
				
				// Create child position perpendicular to the parent's direction
				// instead of behind the parent
				PVector newBlobPosition = new PVector();
				newBlobPosition.x = position.x + perpDirection.x * 20; // Move perpendicular
				newBlobPosition.y = position.y + perpDirection.y * 20;
				
				// Add a body part at this new position
				PVector bodyPartPosition = new PVector();
				bodyPartPosition.x = position.x - velocity.x * 5;
				bodyPartPosition.y = position.y - velocity.y * 5;
				bodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));

				// Create a velocity in the same perpendicular direction
				PVector childVelocity = perpDirection.copy();
				childVelocity.mult(2); // Speed factor

				Blob newBlob = new Blob(newBlobPosition, childVelocity, lastBodyPart);
				blobs.add(newBlob);
				newBlob.maxSpeed = maxSpeed - 0.1;
				newBlob.maxForce = maxForce - 0.01;		
				newBlob.maxLifeSpan = maxLifeSpan - 100;		
			}
			else{
				// add a body just few pixel behind me
				PVector bodyPartPosition = new PVector();
				bodyPartPosition.x = position.x - velocity.x * 5;
				bodyPartPosition.y = position.y - velocity.y * 5;
				bodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));
			}
		}

		// In Blob.update(), consider limiting the max number of bodyParts
		if (bodyParts.size() > 50) {
			bodyParts.remove(0); // Remove oldest bodyPart
		}

	}

	ArrayList<BodyPart> getAllBlobsBodyParts(){
		ArrayList<BodyPart> nearbyBodyParts = new ArrayList<BodyPart>();
  
		// Get nearby cells only
		int cellX = floor(position.x / cellSize);
		int cellY = floor(position.y / cellSize);
  
		// Check current cell and 8 surrounding cells
		for (int i = -1; i <= 1; i++) {
			for (int j = -1; j <= 1; j++) {
				int checkCellX = cellX + i;
				int checkCellY = cellY + j;
				int cellKey = checkCellX * 1000 + checkCellY;
      
				if (grid.containsKey(cellKey)) {
					nearbyBodyParts.addAll(grid.get(cellKey));
				}
			}
		}
  
		return nearbyBodyParts;
	}

	void repulsion(){
		ArrayList<BodyPart> allBodyParts = getAllBlobsBodyParts();

		PVector repulsion = new PVector(0, 0);
		int count = 0;
		int bodyPartCount = 0;
		
		// Body parts repulsion
		for (BodyPart bodyPart : allBodyParts) {
			float distance = PVector.dist(position, bodyPart.position);
			
			if (distance < perceptionRadius && distance > 0) { 
				stroke(0, 10);
				// line(position.x, position.y, bodyPart.position.x, bodyPart.position.y);	
				PVector diff = PVector.sub(position, bodyPart.position);
				diff.normalize();
				
				float weight = 3.0 / (distance * distance);
				diff.mult(weight);
				
				repulsion.add(diff);
				count++;
			}

			bodyPartCount++;
		}
		
		if (count > 0) {
			repulsion.div(count);
			
			// Scale to desired magnitude
			repulsion.normalize();
			repulsion.mult(maxForce);
		}
		
		// Screen border repulsion
		PVector borderRepulsion = new PVector(0, 0);
		float borderMargin = 50; 
		float borderForce = maxForce * 1.5;
		
		if (position.x < borderMargin) {
			float intensity = map(position.x, 0, borderMargin, borderForce, 0);
			borderRepulsion.x += intensity;
		}
		
		if (position.x > width - borderMargin) {
			float intensity = map(position.x, width - borderMargin, width, 0, borderForce);
			borderRepulsion.x -= intensity;
		}
		
		if (position.y < borderMargin) {
			float intensity = map(position.y, 0, borderMargin, borderForce, 0);
			borderRepulsion.y += intensity;
		}
		
		if (position.y > height - borderMargin) {
			float intensity = map(position.y, height - borderMargin, height, 0, borderForce);
			borderRepulsion.y -= intensity;
		}
		
		// Apply both repulsion forces
		repulsion.add(borderRepulsion);
		repulsion.limit(maxForce);
		velocity.add(repulsion);
		velocity.limit(maxSpeed);
	}

	void draw(PGraphics pg) {
		if (pg == null) pg = g; // Use main canvas if no PGraphics provided
		
		pg.fill(0, 100);
		pg.ellipse(position.x, position.y, 10, 10);
	
		// draw the perception radius
		pg.noFill();
		pg.stroke(0, 100);
		pg.ellipse(position.x, position.y, perceptionRadius, perceptionRadius);
	
		// draw a line between all body part in order
		for (int i = 0; i < bodyParts.size() - 1; i++) {
			BodyPart bodyPart1 = bodyParts.get(i);
			BodyPart bodyPart2 = bodyParts.get(i + 1);
			pg.line(bodyPart1.position.x, bodyPart1.position.y, bodyPart2.position.x, bodyPart2.position.y);
		}
	
		if (bodyParts.size() > 0) {
			BodyPart lastBodyPart = bodyParts.get(bodyParts.size() - 1);
			pg.line(position.x, position.y, lastBodyPart.position.x, lastBodyPart.position.y);
		}
	}
	
	void draw() {
		draw(null);
	}
}
