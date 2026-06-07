<?php

namespace App\Controller\Nutriverif;

use Psr\Log\LoggerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;

class NutriverifController extends AbstractController
{
    private HttpClientInterface $httpClient;
    private LoggerInterface $logger;

    public function __construct(HttpClientInterface $httpClient, LoggerInterface $logger)
    {
        $this->httpClient = $httpClient;
        $this->logger = $logger;
    }

    #[Route('/search-products', name: 'search_products', methods: ['POST'])]
    public function search(Request $request): JsonResponse
    {
        try {
            $data = $request->toArray();
            $url = $data['url'] ?? null;
            $method = strtoupper($data['method'] ?? 'GET');

            if (!isset($url)) {
                $this->logger->warning('NutriVerif: Tentative d\'appel sans paramètre "url".');
                return $this->json(
                    ['error' => 'Le paramètre "url" est requis.'],
                    Response::HTTP_BAD_REQUEST
                );
            }

            $response = $this->httpClient->request($method, $url, [
                'headers' => [
                    'User-Agent' => 'NutriVérif/1.0 (sokhona.salaha@gmail.com)',
                ],
            ]);
            $content = $response->getContent();

            $statusCode = $response->getStatusCode();
            $this->logger->info('NutriVerif: Réponse OFF', [
                'status' => $statusCode,
                'content_type' => $response->getHeaders()['content-type'][0] ?? 'unknown',
                'preview' => substr($content, 0, 300)
            ]);

            return $this->json($response->toArray());
        } catch (\Exception $e) {
            $this->logger->critical('NutriVerif: Crash du contrôleur ! Message : ' . $e->getMessage(), [
                'exception' => $e
            ]);

            return $this->json(
                ['error' => 'Une erreur interne est survenue.', 'details' => $e->getMessage()],
                Response::HTTP_INTERNAL_SERVER_ERROR
            );
        }
    }
}
