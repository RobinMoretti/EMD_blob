class Blob{
	PVector position, velocity, acceleration;
	ArrayList<BodyPart> bodyParts = new ArrayList<BodyPart>();
	ArrayList<Blob> children = new ArrayList<Blob>();



	float maxSpeed = 1;
	float maxForce = 0.1;
	float minDistance = 25;
	float perceptionRadius = 30;

	Blob(){
		position = new PVector();
		velocity = new PVector();
		acceleration = new PVector();

		position.x = width/2;
		position.y = height/2;
		
		// go in a random direction
		velocity.x = random(-1, 1);
		velocity.y = random(-1, 1);

		//add few body part randomly around my position
		for (int i = 0; i < random(2, 5); i++) {
			PVector bodyPartPosition = new PVector();
			bodyPartPosition.x = position.x + random(-50, 50);
			bodyPartPosition.y = position.y + random(-50, 50);
			bodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));
		}
	} 

	void update(){
		repulsion();
		
		// Add some randomness to the velocity
		PVector randomForce = PVector.random2D();
		randomForce.mult(0.15); 
		velocity.add(randomForce);
		
		position.add(velocity);

		draw();

		for (BodyPart bodyPart : bodyParts) {
			bodyPart.draw();
		}
	}

		void repulsion(){
		PVector repulsion = new PVector(0, 0);
		int count = 0;
		
		// Body parts repulsion
		for (BodyPart bodyPart : bodyParts) {
			float distance = PVector.dist(position, bodyPart.position);
			
			if (distance < perceptionRadius && distance > 0) { 
				PVector diff = PVector.sub(position, bodyPart.position);
				diff.normalize();
				
				float weight = 1.0 / (distance * distance);
				diff.mult(weight);
				
				repulsion.add(diff);
				count++;
			}
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

	void draw(){
		fill(0, 100);
		ellipse(position.x, position.y, 10, 10);

		// draw the perception radius
		noFill();
		stroke(0, 100);
		ellipse(position.x, position.y, perceptionRadius, perceptionRadius);


		// draw a line between all body part in order
		for (int i = 0; i < bodyParts.size() - 1; i++) {
			BodyPart bodyPart1 = bodyParts.get(i);
			BodyPart bodyPart2 = bodyParts.get(i + 1);
			line(bodyPart1.position.x, bodyPart1.position.y, bodyPart2.position.x, bodyPart2.position.y);
		}

		BodyPart lastBodyPart = bodyParts.get(bodyParts.size() - 1);
		line(position.x, position.y, lastBodyPart.position.x, lastBodyPart.position.y);

		float distance = PVector.dist(position, lastBodyPart.position);
		
		if(distance > minDistance){
			// add a body just few pixel behind me
			PVector bodyPartPosition = new PVector();
			bodyPartPosition.x = position.x - velocity.x * 5;
			bodyPartPosition.y = position.y - velocity.y * 5;
			bodyParts.add(new BodyPart(bodyPartPosition, random(5, 10)));

			if(bodyParts.size() > 10){
				// children.add(new Blob());
			}
		}


		for (Blob child : children) {
			child.update();
		}
	}

}