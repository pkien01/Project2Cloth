PrintWriter en_output;
PrintWriter len_output;

int n = 25, m = 25;
void setup() {
  size(800, 800, P3D);
  //fullScreen(P3D);
  surface.setTitle("Double Pendulum");
  scene_scale = width / 10.0f;
  for(int i = 0; i < n; i++)
  {
     for (int j = 0; j < m; j++) {
       nodes[i][j] = new Node(base_pos.plus(new Vec3(i*link_length, j*link_length, 0)), 1.f);
    }  
  }  
}


// Node struct
class Node {
  Vec3 pos;
  Vec3 last_pos;
  Vec3 vel;
  float mass;
  
  Node(Vec3 pos, float mass) {
    this.pos = pos;
    this.vel = new Vec3(0, 0, 0);
    this.mass = mass;
  }
}

// Link length
float link_length = 0.2;
float tot_energy;
float tot_len_error;

// Nodes
Vec3 base_pos = new Vec3(10, 0, 0);
Node nodes[][] = new Node[n+1][m+1];

// Gravity
Vec3 gravity = new Vec3(0, 9.8, 0);


// Scaling factor for the scene
float scene_scale = width / 10.0f;
float spring_const = 40.f;
float damp_factor = 10;

int dx[] = {-1, -1, 0, 1, 1, 1, 0, -1};
int dy[] = {0,  1,  1, 1, 0, -1, -1, -1};
void update_point(int x, int y, int dir, float dt) {
   int nx = x + dx[dir], ny = y + dy[dir];
   if (nx < 0 || nx >= n || ny < 0 || ny >= m) return;
   Vec3 e = nodes[nx][ny].last_pos.minus(nodes[x][y].last_pos);
   float len = e.length();
   e.normalize();
   float v1 = dot(e, nodes[x][y].vel), v2 = dot(e, nodes[nx][ny].vel);
   float l0 = (dx[dir] == 0 || dy[dir] == 0)? link_length : sqrt(2)*link_length;
    float force = -spring_const*(l0 - len) - damp_factor*(v1 - v2);
    nodes[x][y].vel.add(e.times(force*dt));
    nodes[nx][ny].vel.subtract(e.times(force*dt));
}
void collide_mouse(int x, int y) {
  Vec3 delta = sphere_pos.minus(nodes[x][y].last_pos);
   float dist = delta.length();
   println("dist: " + dist);
   if (dist > sphere_radius) return;
   Vec3 normal = delta.times(-1).normalized();
   Vec3 bounce = normal.times(dot(nodes[x][y].vel, normal));
   nodes[x][y].vel.subtract(bounce.times(1.5));
   nodes[x][y].pos.add(normal.times(.1 + sphere_radius - dist));
}
void update_physics(float dt) {
   for (int i = 0; i < n; i++) {
     for (int j = 0; j < m; j++) {
       nodes[i][j].last_pos = nodes[i][j].pos;
        if (j == 0) continue;
       nodes[i][j].pos.add(nodes[i][j].vel.times(dt));
       nodes[i][j].vel.add(gravity.times(dt));
     }
  }
  for(int i = 0; i < n; i++)
  {
    for (int j = 0; j < m; j++) {
       for (int k = 0; k < 8; k++) {
         update_point(i, j, k, dt);
       }
    }
  }

  for (int i = 0; i < n; i++) {
      nodes[i][0].vel = nodes[i][0].pos.minus(nodes[i][0].last_pos).times(1/dt);
       nodes[i][0].pos = nodes[i][0].last_pos;
   }
}

Vec3 sphere_pos;
float sphere_radius = 2;

void mouseClicked() {
  sphere_pos = new Vec3(mouseX/scene_scale, mouseY/scene_scale, 0);
  for (int i = 0; i < n; i++)
    for (int j = 0; j < m; j++)
      collide_mouse(i, j);
}

boolean paused = false;

void keyPressed() {
  if (key == ' ') {
    paused = !paused;
  }
}

float time = 0;

float angle = 0.;
void draw() {
  //float dt = 1.0 / 20; //Dynamic dt: 1/frameRate;
  float dt = 0.05;
  
  if (!paused) {
    update_physics(dt);
  }

  background(255);
  stroke(0);
  strokeWeight(2);
  fill(0, 255, 0);
  stroke(0);
  strokeWeight(0.02 * scene_scale);
  noStroke();
  lights();
  
  PImage img = loadImage("diamond_ore.png");
  textureMode(NORMAL); 
  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < m - 1; j++) {
      beginShape();
      texture(img);
      vertex(nodes[i][j].pos.x * scene_scale, nodes[i][j].pos.y * scene_scale, nodes[i][j].pos.z * scene_scale, 0, 0);
      vertex(nodes[i][j + 1].pos.x * scene_scale, nodes[i][j + 1].pos.y * scene_scale, nodes[i][j + 1].pos.z * scene_scale, 0, 1);
      vertex(nodes[i+ 1][j + 1].pos.x * scene_scale, nodes[i + 1][j + 1].pos.y * scene_scale, nodes[i + 1][j + 1].pos.z * scene_scale, 1, 1);
      vertex(nodes[i + 1][j].pos.x * scene_scale, nodes[i + 1][j].pos.y * scene_scale, nodes[i + 1][j].pos.z * scene_scale, 1, 0);
      endShape();
    }
  }
  /*for(int i = 0; i < n; i++)
  { 
    for (int j = 0; j < m; j++) {
      pushMatrix();
      translate(nodes[i][j].pos.x * scene_scale, nodes[i][j].pos.y * scene_scale, nodes[i][j].pos.z * scene_scale);
      sphere(0.3 * scene_scale / 6);
      popMatrix();
    }
  }*/
  /*
  for(int i = 0; i < n; y++)
  {
    stroke(0);
    strokeWeight(0.02 * scene_scale);
    line(nodes[y].pos.x * scene_scale, nodes[y].pos.y * scene_scale, nodes[y].pos.z * scene_scale, nodes[y+1].pos.x * scene_scale, nodes[y+1].pos.y * scene_scale, nodes[y+1].pos.z * scene_scale);
  }*/
}


//---------------
//Vec 2 Library
//---------------

//Vector Library
//CSCI 5611 Vector 2 Library [Example]
// Stephen J. Guy <sjguy@umn.edu>

public class Vec3 {
  public float x, y, z;

  public Vec3(float x, float y, float z) {
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

  public Vec3 plus(Vec3 rhs) {
    return new Vec3(x + rhs.x, y + rhs.y, z + rhs.z);
  }

  public void add(Vec3 rhs) {
    x += rhs.x;
    y += rhs.y;
    z += rhs.z;
  }

  public Vec3 minus(Vec3 rhs) {
    return new Vec3(x - rhs.x, y - rhs.y, z - rhs.z);
  }

  public void subtract(Vec3 rhs) {
    x -= rhs.x;
    y -= rhs.y;
    z -= rhs.z;
  }

  public Vec3 times(float rhs) {
    return new Vec3(x * rhs, y * rhs, z * rhs);
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

  public Vec3 normalized() {
    float magnitude = sqrt(x * x + y * y + z * z);
    return new Vec3(x / magnitude, y / magnitude, z / magnitude);
  }

  public float distanceTo(Vec3 rhs) {
    float dx = rhs.x - x;
    float dy = rhs.y - y;
    float dz = rhs.z - z ;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }
}

Vec3 interpolate(Vec3 a, Vec3 b, float t) {
  return a.plus((b.minus(a)).times(t));
}

float interpolate(float a, float b, float t) {
  return a + ((b - a) * t);
}

float dot(Vec3 a, Vec3 b) {
  return a.x * b.x + a.y * b.y;
}

// 2D cross product is a funny concept
// ...its the 3D cross product but with z = 0
// ... (only the resulting z component is not zero so we just store it as a scalar)
float cross(Vec3 a, Vec3 b) {
  return a.x * b.y - a.y * b.x;
}

Vec3 projAB(Vec3 a, Vec3 b) {
  return b.times(a.x * b.x + a.y * b.y);
}

Vec3 perpendicular(Vec3 a) {
  return new Vec3(-a.y, a.x, a.z);
}
