Forward process: pick two images: $I^c$ is the image we condition on, $I^t$ is the image whose probability we predict. Extract patches $Q^c$ and $Q^t$ from each , and compute $P(Q^t | Q^c)$


\begin{align}
 v(x) &= N_\theta^{AB}(x) - N_\theta^{BA}(x) \\
 \frac{\partial}{\partial t} \Phi^{AB}(x, t) &= v(x)\\
 \Phi^{AB}(x, 0) &= x \\
 \Phi^{AB}(x) &= \Phi^{AB}(x, 1)
\end{align}
