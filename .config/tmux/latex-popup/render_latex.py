#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = ["matplotlib"]
# ///
"""
Extract LaTeX from stdin and render to PNG.
Outputs the path to the rendered image.
"""

import re
import sys
import tempfile
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# Patterns that delimit LaTeX expressions
LATEX_DELIMITERS = [
    r'\$\$(.+?)\$\$',                              # $$...$$
    r'(?<!\$)\$(?!\$)(.+?)\$',                     # $...$ (not $$)
    r'\\\[(.+?)\\\]',                              # \[...\]
    r'\\begin\{equation\}(.+?)\\end\{equation\}',  # \begin{equation}...\end{equation}
    r'\\begin\{align\}(.+?)\\end\{align\}',        # \begin{align}...\end{align}
]

# What makes something look like LaTeX (vs. coincidental dollar signs)
LATEX_COMMAND = re.compile(r'\\[a-zA-Z]+')

# Rendering style
STYLE = {
    'bg_color': '#2d2518',
    'text_color': '#f5f5f5',
    'fontset': 'cm',
    'fontsize': 14,
    'dpi': 150,
    'fig_width': 8,
    'row_height': 0.9,
    'min_height': 1.2,
}


def find_candidates(text: str) -> list[str]:
    """Find all strings that might be LaTeX expressions."""
    candidates = []
    for pattern in LATEX_DELIMITERS:
        candidates.extend(re.findall(pattern, text, re.DOTALL))
    return candidates


def is_valid_latex(expr: str) -> bool:
    """Check if a candidate string looks like actual LaTeX."""
    expr = expr.strip()
    if not LATEX_COMMAND.search(expr):
        return False
    if '\n' in expr:
        return False
    if len(expr) > 300:
        return False
    return True


def extract_latex(text: str) -> list[str]:
    """Extract valid LaTeX expressions from text."""
    candidates = find_candidates(text)
    return [c.strip() for c in candidates if is_valid_latex(c)]


def render(expressions: list[str], outpath: Path) -> bool:
    """Render LaTeX expressions to PNG, stacked vertically."""
    matplotlib.rcParams['mathtext.fontset'] = STYLE['fontset']

    n = len(expressions)
    fig_height = max(STYLE['min_height'], n * STYLE['row_height'])

    fig, ax = plt.subplots(figsize=(STYLE['fig_width'], fig_height))
    ax.set_facecolor(STYLE['bg_color'])
    fig.patch.set_facecolor(STYLE['bg_color'])
    ax.axis('off')

    for i, latex in enumerate(expressions):
        y = 1 - (i + 0.5) / n
        ax.text(
            0.5, y, f'${latex}$',
            fontsize=STYLE['fontsize'],
            color=STYLE['text_color'],
            ha='center', va='center',
            transform=ax.transAxes,
        )

    fig.savefig(
        outpath,
        bbox_inches='tight',
        pad_inches=0.3,
        dpi=STYLE['dpi'],
        facecolor=STYLE['bg_color'],
    )
    plt.close(fig)
    return True


def main():
    text = sys.stdin.read()
    expressions = extract_latex(text)

    if not expressions:
        print("No LaTeX found", file=sys.stderr)
        sys.exit(1)

    outpath = Path(tempfile.gettempdir()) / "latex_render.png"

    try:
        render(expressions, outpath)
        print(outpath)
    except Exception as e:
        print(f"Render failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
