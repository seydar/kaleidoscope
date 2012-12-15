extern putchard(a);
extern putd(a);
for i = 1, 100, 0.1 in
  cur = i,
  putd(i),
  putchard(13);

. jit.gc.stats
