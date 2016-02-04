/*
  Homework 1
  Implementing head - Part 2 & 3
  CS 3224
  Erich Chu
*/

#include "types.h"
#include "stat.h"
#include "user.h"

char buf[512];

void head(int fd, int lines) {
  int i,n,l;
  i=n=l= 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i=0; i<n; i++){
      if(l > lines) 
        exit();
      if(buf[i] == '\n')
          l++;
      printf(1,"%c", buf[i]);
    }
  }
  if(n < 0){
    printf(1, "head: read error\n");
    exit();
  }
}

int main(int argc, char *argv[])
{
  int fd, i, lines;
  if(argc >2) {
    lines = atoi(argv[1] + 1);
  }
  else lines = 10;
  if(argc <= 1){
    head(0, lines);
    exit();
  }
  for(i = 1; i < argc; i++){
    if(argc <= 2 && (fd = open(argv[i], 0)) < 0){
      printf(1, "head: cannot open %s\n", argv[i]);
      exit();
    }
    else if(argc > 2 && i > 1 && (fd = open(argv[i], 0)) < 0){
      printf(1, "head: cannot open %s\n", argv[i]);
      exit();
    }
    if((argc>2 && i>1) || argc <=2)
      head(fd, lines);
    close(fd);
  }
  exit();
}
