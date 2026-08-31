
For a cell (X, Y), 0 < X < (W - 1) and 0 < Y < (H - 1):
    (X - 1, Y - 1)  (X, Y - 1)  (X + 1, Y - 1)
    (X - 1, Y)      (X, Y)      (X + 1, Y)
    (X - 1, Y + 1)  (X, Y + 1)  (X + 1, Y + 1)

For a cell (0, Y), 0 < Y < (H - 1)
    (W - 1, Y - 1)  (X, Y - 1)  (X + 1, Y - 1)
    (W - 1, Y)      (X, Y)      (X + 1, Y)
    (W - 1, Y - 1)  (X, Y + 1)  (X + 1, Y + 1)

For a cell (W - 1, Y), 0 < Y < (H - 1)
    (X - 1, Y - 1)  (X, Y - 1)  (0, Y - 1)
    (X - 1, Y)      (X, Y)      (0, Y)
    (X - 1, Y - 1)  (X, Y + 1)  (0, Y + 1)


N1 N2 N3
N4    N5
N6 N7 N8

Suppose that
    V = address of the subject cell
    W = grid width in cells
    H = grid height in cells
    X = column index of the subject cell; 0 <= X < W
    Y = row index of the subject cell; 0 <= Y < H

    edge_W = X == 0
    edge_E = X == W - 1
    edge_N = Y == 0
    edge_S = Y == H - 1

cases:
    ; NW corner: edge_W AND edge_N             
        N1 has coordinates (W - 1, H - 1) and is located at V + W*H - 1
        N2 has coordinates (X, H - 1) and is located at V + W*(H - 1) + X
        N3 has coordinates (X + 1, H - 1) and is located at V + W*(H - 1) + X + 1
        N4 has coordinates (W - 1, Y) and is located at V + W - 1
        N5 has coordinates (X + 1, Y) and is located at V + 1
        N6 has coordinates (W - 1, Y + 1) and is located at V + 2*W+1
        N7 has coordinates (X, Y + 1) and is located at V + W
        N8 has coordinates (X + 1, Y + 1) and is located at V + W + 1

    : NE corner: edge_E AND edge_N
    : SW corner: edge_W AND edge_S
    : SE corner: edge_E AND edge_S

    : N border: !edge_W AND !edge_E AND edge_N
    : W border: edge_W AND !edge_N AND !edge_S
    ; S border: !edge_W AND !edge_E AND edge_S
    ; E border: edge_E AND !edge_N AND !edge_S

    ; otherwise: 0 < X < W - 1, 0 < Y <  H - 1
    



