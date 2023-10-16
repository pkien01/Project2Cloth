PrintWriter en_output;
PrintWriter len_output;

void setup() {
  size(500, 500, P3D);
  surface.setTitle("Double Pendulum");
  scene_scale = width / 10.0f;
  nodes[0] = new Node(base_pos);
  kin_energy[0] = 0;
  pot_energy[0] = 0;
  for(int i = 1; i< 20; i++)
  {
    nodes[i] = new Node(new Vec2(base_pos.x+(i*link_length), base_pos.y, 3));
    kin_energy[i] = 0;
    pot_energy[i] = 0;
  }  
}

void energy_calc()
{
  tot_energy = 0;
  for(int i = 0; i < 20; i++)
  {
    kin_energy[i] = 0;
    pot_energy[i] = 0;
    kin_energy[i] += 0.5 * nodes[i].vel.lengthSqr();
    float h_b = (height - nodes[i].pos.y * scene_scale) / scene_scale;
    pot_energy[i] += gravity.y * h_b;
    tot_energy += kin_energy[i] + pot_energy[i];
  }
}

void len_err()
{
  tot_len_error = 0;
  for(int i = 1; i< 20; i++)
  {
    float cur_len = nodes[i].pos.distanceTo(nodes[i-1].pos);
    float len_error = abs(cur_len - link_length);
    tot_len_error += len_error;
  }
}

// Node struct
class Node {
  Vec2 pos;
  Vec2 vel;
  Vec2 last_pos;

  Node(Vec2 pos) {
    this.pos = pos;
    this.vel = new Vec2(0, 0, 0);
    this.last_pos = pos;
  }
}

// Link length
float link_length = 0.2;
float kin_energy[] = new float[20];
float pot_energy[] = new float[20];
float tot_energy;
float tot_len_error;

// Nodes
Vec2 base_pos = new Vec2(3, 5, 3);
Node nodes[] = new Node[20];

// Gravity
Vec2 gravity = new Vec2(0, 10, 0);


// Scaling factor for the scene
float scene_scale = width / 10.0f;

// Physics Parameters
int sub_steps = 1;
int relaxation_steps = 100;

void update_physics(float dt) {
  
  for(int i = 1; i < 20; i++)
  {
    nodes[i].last_pos = nodes[i].pos;
    nodes[i].vel = nodes[i].vel.plus(gravity.times(dt));
    nodes[i].pos = nodes[i].pos.plus(nodes[i].vel.times(dt));
  }

  // Constrain the distance between nodes to the link length
  for (int i = 0; i < relaxation_steps; i++) {
    
    for(int j = 1; j < 20; j++)
    {
      Vec2 delta = nodes[j].pos.minus(nodes[j-1].pos);
      float delta_len = delta.length();
      float correction = delta_len - link_length;
      Vec2 delta_normalized = delta.normalized();
      nodes[j].pos = nodes[j].pos.minus(delta_normalized.times(correction / 2));
      nodes[j-1].pos = nodes[j-1].pos.plus(delta_normalized.times(correction / 2));
      
    }
    nodes[0].pos = base_pos;
  }

  
  len_err();
  for(int k = 0; k < 20; k++)
  {
    nodes[k].vel = nodes[k].pos.minus(nodes[k].last_pos).times(1/dt);
  }
}

boolean paused = false;

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}

float time = 0;
void draw() {
  //float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
  float dt = 0.05;
  
  if (!paused) {
    for (int i = 0; i < sub_steps; i++) {
      time += dt / sub_steps;
      update_physics(dt / sub_steps);
    }
  }
  
  energy_calc();

  background(255);
  stroke(0);
  strokeWeight(2);
  fill(0, 255, 0);
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  noStroke();
  lights();
  
  for(int h = 0; h < 20; h++)
  { 
    pushMatrix();
    translate(nodes[h].pos.x * scene_scale, nodes[h].pos.y * scene_scale, nodes[h].pos.z * scene_scale);
    sphere(0.3 * scene_scale / 6);
    popMatrix();
  }
  
  for(int y = 0; y < 19; y++)
  {
    stroke(0);
    strokeWeight(0.02 * scene_scale);
    line(nodes[y].pos.x * scene_scale, nodes[y].pos.y * scene_scale, nodes[y].pos.z * scene_scale, nodes[y+1].pos.x * scene_scale, nodes[y+1].pos.y * scene_scale, nodes[y+1].pos.z * scene_scale);
  }
}



//---------------
//Vec 2 Library
//---------------

//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec2 {
  public float x, y, z;

  public Vec2(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public String toString() {
    return "(" + x + "," + y + ")";
  }

  public float length() {
    return sqrt(x * x + y * y + z * z);
  }

  public float lengthSqr() {
    return x * x + y * y + z * z;
  }

  public Vec2 plus(Vec2 rhs) {
    return new Vec2(x + rhs.x, y + rhs.y, z + rhs.z);
  }

  public void add(Vec2 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }

  public Vec2 minus(Vec2 rhs) {
    return new Vec2(x - rhs.x, y - rhs.y, z - rhs.z);
  }

  public void subtract(Vec2 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }

  public Vec2 times(float rhs) {
    return new Vec2(x * rhs, y * rhs, z * rhs);
  }

  public void mul(float rhs) {
    x *= rhs;
    y *= rhs;
    z *= rhs;
  }

  public void clampToLength(float maxL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    if (magnitude > maxL) {
      x *= maxL / magnitude;
      y *= maxL / magnitude;
      z *= maxL / magnitude;
    }
  }

  public void setToLength(float newL) {
    float magnitude = sqrt(x * x + y * y + z * z);
    x *= newL / magnitude;
    y *= newL / magnitude;
    z *= newL / magnitude;
  }

  public void normalize() {
    float magnitude = sqrt(x * x + y * y + z * z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }

  public Vec2 normalized() {
    float magnitude = sqrt(x * x + y * y + z * z);
    return new Vec2(x / magnitude, y / magnitude, z / magnitude);
  }

  public float distanceTo(Vec2 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z ;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

Vec2 interpolate(Vec2 a, Vec2 b, float t) {
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
  return a + ((b - a) * t);
}

float dot(Vec2 a, Vec2 b) {
  return a.x * b.x + a.y * b.y;
}

// 2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z component is not zero so we just store it as a scalar)
float cross(Vec2 a, Vec2 b) {
  return a.x * b.y - a.y * b.x;
}

Vec2 projAB(Vec2 a, Vec2 b) {
  return b.times(a.x * b.x + a.y * b.y);
}

Vec2 perpendicular(Vec2 a) {
  return new Vec2(-a.y, a.x, a.z);
}
